#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
LOGDIR="$ROOT/logs/toolchain"
SRC="$ROOT/sources"
JOBS="${JOBS:-$(nproc)}"
TARGET="${LFS_TGT:-x86_64-lfs-linux-gnu}"
# Préfixe LFS/tools pour que le binaire as/ld cross soit résolu avant l'hôte.
export PATH="$LFS/tools/bin:$ROOT/.local/bin:$PATH"

mkdir -p "$LOGDIR" "$SRC" "$LFS/tools"

echo "[!] Script squelette: téléchargez/validez les tarballs avant build."

require_tarball() {
	local tar="$1"
	if [ ! -f "$SRC/$tar" ]; then
		echo "[ERR] Tarball manquant: $SRC/$tar" >&2
		exit 1
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

case "${1:-}" in
	binutils) build_binutils ;;
	gcc-stage1) build_gcc_stage1 ;;
	libgcc) build_libgcc ;;
	gcc) build_gcc ;;
	linux-headers) build_linux_headers ;;
	glibc) build_glibc_headers ;;
	all) build_binutils; build_gcc_stage1; build_linux_headers; build_glibc_headers; build_libgcc ;;
	*) echo "Usage: $0 {binutils|gcc-stage1|libgcc|gcc|linux-headers|glibc|all}" >&2; exit 1 ;;
esac
