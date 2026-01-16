#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
LOGDIR="$ROOT/logs/toolchain"
SRC="$ROOT/sources"
JOBS="${JOBS:-$(nproc)}"
TARGET="${LFS_TGT:-x86_64-lfs-linux-gnu}"
STATE_FILE="$ROOT/work/build_toolchain.state"
TIMING_LOG="$LOGDIR/build_times.csv"
PROGRESS_LOG="$ROOT/reports/build_progress.csv"
GROUP="toolchain"
RESUME=0
RESET_STATE=0
SHOW_STATUS=0
DRY_RUN=0
# Préfixe LFS/tools pour que le binaire as/ld cross soit résolu avant l'hôte.
export PATH="$LFS/tools/bin:$ROOT/.local/bin:$PATH"

mkdir -p "$LOGDIR" "$SRC" "$LFS/tools" "$ROOT/reports"

echo "[!] Script squelette: téléchargez/validez les tarballs avant build."

require_tarball() {
	local tar="$1"
	if [ ! -f "$SRC/$tar" ]; then
		echo "[ERR] Tarball manquant: $SRC/$tar" >&2
		exit 1
	fi
}

usage() {
	cat <<EOF
Usage: $0 [options] {binutils|gcc-stage1|libgcc|gcc|linux-headers|glibc|all}

Options:
  --lfs <dir>           Racine LFS cible
  --jobs <n>            Parallélisme make
  --resume              Ignore les étapes déjà dans l'état
  --reset-state         Supprime l'état avant exécution
  --show-status         Affiche l'état et quitte
  --dry-run             N'exécute pas, trace seulement
  --state <file>        Fichier d'état
  --timing-log <file>   CSV des timings
  --progress-log <file> CSV de progression
EOF
	exit 1
}

state_has() {
	local name="$1"
	[ -f "$STATE_FILE" ] && grep -Fxq "$name" "$STATE_FILE"
}

record_state() {
	local name="$1"
	[ "$DRY_RUN" -eq 1 ] && return
	mkdir -p "$(dirname "$STATE_FILE")"
	echo "$name" >>"$STATE_FILE"
}

timing_init() {
	if [ ! -f "$TIMING_LOG" ]; then
		echo "step,version,start,end,duration_sec,status" >"$TIMING_LOG"
	fi
}

progress_init() {
	local dir
	dir="$(dirname "$PROGRESS_LOG")"
	mkdir -p "$dir"
	if [ ! -f "$PROGRESS_LOG" ]; then
		echo "timestamp,group,package,version,build_type,status,duration_sec" >"$PROGRESS_LOG"
	fi
}

record_progress() {
	local name="$1" version="$2" status_label="$3" duration="$4"
	progress_init
	echo "$(date '+%Y-%m-%d %H:%M:%S'),$GROUP,$name,$version,toolchain,$status_label,$duration" >>"$PROGRESS_LOG"
}

run_step() {
	local name="$1" version="$2" fn="$3"
	if [ "$RESUME" -eq 1 ] && state_has "$name"; then
		echo "[skip] $name ($version)"
		record_progress "$name" "$version" "skip" 0
		return 0
	fi
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] $name ($version)"
		record_progress "$name" "$version" "dry_run" 0
		return 0
	fi
	timing_init
	local start end duration
	start=$(date +%s)
	set +e
	"$fn"
	local status=$?
	set -e
	end=$(date +%s)
	duration=$((end - start))
	if [ "$status" -eq 0 ]; then
		record_state "$name"
		record_progress "$name" "$version" "ok" "$duration"
		echo "$name,$version,$start,$end,$duration,ok" >>"$TIMING_LOG"
	else
		record_progress "$name" "$version" "fail" "$duration"
		echo "$name,$version,$start,$end,$duration,fail" >>"$TIMING_LOG"
		return "$status"
	fi
}

prepare_gcc_tree() {
	local pkg=gcc-13.2.0
	require_tarball "$pkg.tar.xz"
	for dep in gmp-6.3.0 mpfr-4.2.1 mpc-1.3.1; do
		if [ -f "$dep.tar.xz" ]; then
			:
		elif [ -f "$dep.tar.gz" ]; then
			:
		else
			require_tarball "$dep.tar.xz"
		fi
	done
	if [ ! -d "$pkg" ]; then
		tar xf "$pkg".tar.xz
		[ -f gmp-6.3.0.tar.xz ] && tar xf gmp-6.3.0.tar.xz
		[ -f gmp-6.3.0.tar.gz ] && tar xf gmp-6.3.0.tar.gz
		[ -f mpfr-4.2.1.tar.xz ] && tar xf mpfr-4.2.1.tar.xz
		[ -f mpfr-4.2.1.tar.gz ] && tar xf mpfr-4.2.1.tar.gz
		[ -f mpc-1.3.1.tar.gz ] && tar xf mpc-1.3.1.tar.gz
		[ -f mpc-1.3.1.tar.xz ] && tar xf mpc-1.3.1.tar.xz
		mv gmp-6.3.0 "$pkg"/gmp
		mv mpfr-4.2.1 "$pkg"/mpfr
		mv mpc-1.3.1 "$pkg"/mpc
	fi
}

build_binutils() {
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] binutils-2.43.1 configure/make/install"
		return
	fi
	cd "$SRC"
	local pkg=binutils-2.43.1
	require_tarball "$pkg.tar.xz"
	[ -d "$pkg" ] || tar xf "$pkg".tar.xz
	mkdir -p "$pkg-build"
	cd "$pkg-build"
	export MAKEINFO=/bin/true
	"$MAKEINFO" --version >/dev/null 2>&1 || true
	../"$pkg"/configure --prefix="$LFS/tools" --with-sysroot="$LFS" --target="$TARGET" --disable-nls --disable-werror >"$LOGDIR/binutils.config.log"
	MAKEINFO=/bin/true make -j"$JOBS" >"$LOGDIR/binutils.make.log"
	MAKEINFO=/bin/true make install >"$LOGDIR/binutils.install.log"
}

build_gcc_stage1() {
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] gcc-13.2.0 stage1 configure/make/install"
		return
	fi
	cd "$SRC"
	local pkg=gcc-13.2.0
	prepare_gcc_tree
	mkdir -p "$pkg-build"
	cd "$pkg-build"
	../"$pkg"/configure --target="$TARGET" --prefix="$LFS/tools" --with-glibc-version=2.40 --with-sysroot="$LFS" --with-newlib --without-headers --enable-initfini-array --disable-nls --disable-shared --disable-multilib --disable-decimal-float --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++ >"$LOGDIR/gcc.config.log"
	make -j"$JOBS" all-gcc >"$LOGDIR/gcc.stage1.make.log"
	make install-gcc >"$LOGDIR/gcc.stage1.install.log"
}

build_libgcc() {
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] gcc-13.2.0 libgcc make/install"
		return
	fi
	cd "$SRC"
	local pkg=gcc-13.2.0
	local build_dir="$SRC/$pkg-build"
	if [ ! -d "$build_dir" ]; then
		echo "[ERR] gcc build dir missing: $build_dir" >&2
		echo "      Run gcc-stage1 first." >&2
		exit 1
	fi
	cd "$build_dir"
	make -j"$JOBS" all-target-libgcc >"$LOGDIR/gcc.libgcc.make.log"
	make install-target-libgcc >"$LOGDIR/gcc.libgcc.install.log"
}

build_gcc() {
	build_gcc_stage1
	build_libgcc
}

build_linux_headers() {
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] linux-6.6.54 headers"
		return
	fi
	cd "$SRC"
	local pkg=linux-6.6.54
	require_tarball "$pkg.tar.xz"
	[ -d "$pkg" ] || tar xf "$pkg".tar.xz
	cd "$pkg"
	make mrproper >"$LOGDIR/linux.mrproper.log"
	make headers >"$LOGDIR/linux.headers.log"
	find usr/include -name '.*' -delete
	rm -f usr/include/Makefile
	mkdir -p "$LFS/usr"
	cp -rv usr/include "$LFS/usr"
}

build_glibc_headers() {
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] glibc-2.40 headers/install"
		return
	fi
	cd "$SRC"
	local pkg=glibc-2.40
	require_tarball "$pkg.tar.xz"
	[ -d "$pkg" ] || tar xf "$pkg".tar.xz
	mkdir -p "$pkg-build"
	cd "$pkg-build"
	../"$pkg"/configure --prefix=/usr --host="$TARGET" --build="$(../"$pkg"/scripts/config.guess)" --enable-kernel=4.14 --with-headers="$LFS/usr/include" libc_cv_slibdir=/usr/lib >"$LOGDIR/glibc.config.log"
	make -j"$JOBS" >"$LOGDIR/glibc.make.log"
	make DESTDIR="$LFS" install >"$LOGDIR/glibc.install.log"
}

ACTION=""
while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs) LFS="$2"; shift 2 ;;
		--jobs) JOBS="$2"; shift 2 ;;
		--resume) RESUME=1; shift ;;
		--reset-state) RESET_STATE=1; shift ;;
		--show-status) SHOW_STATUS=1; shift ;;
		--dry-run) DRY_RUN=1; shift ;;
		--state) STATE_FILE="$2"; shift 2 ;;
		--timing-log) TIMING_LOG="$2"; shift 2 ;;
		--progress-log) PROGRESS_LOG="$2"; shift 2 ;;
		binutils|gcc-stage1|libgcc|gcc|linux-headers|glibc|all)
			ACTION="$1"
			shift
			;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

if [ "$RESET_STATE" -eq 1 ]; then
	rm -f "$STATE_FILE"
fi

if [ "$SHOW_STATUS" -eq 1 ]; then
	echo "state_file: $STATE_FILE"
	for step in binutils gcc-stage1 linux-headers glibc libgcc; do
		if state_has "$step"; then
			echo "$step: done"
		else
			echo "$step: pending"
		fi
	done
	exit 0
fi

case "$ACTION" in
	binutils) run_step "binutils" "2.43.1" build_binutils ;;
	gcc-stage1) run_step "gcc-stage1" "13.2.0" build_gcc_stage1 ;;
	libgcc) run_step "libgcc" "13.2.0" build_libgcc ;;
	gcc)
		run_step "gcc-stage1" "13.2.0" build_gcc_stage1
		run_step "libgcc" "13.2.0" build_libgcc
		;;
	linux-headers) run_step "linux-headers" "6.6.54" build_linux_headers ;;
	glibc) run_step "glibc" "2.40" build_glibc_headers ;;
	all)
		run_step "binutils" "2.43.1" build_binutils
		run_step "gcc-stage1" "13.2.0" build_gcc_stage1
		run_step "linux-headers" "6.6.54" build_linux_headers
		run_step "glibc" "2.40" build_glibc_headers
		run_step "libgcc" "13.2.0" build_libgcc
		;;
	*)
		usage
		;;
esac
