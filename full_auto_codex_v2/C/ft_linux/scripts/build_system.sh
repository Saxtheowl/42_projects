#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-/mnt/lfs}"
LOGDIR="$ROOT/logs/system"
SRC="$ROOT/sources"
JOBS="${JOBS:-$(nproc)}"
MANIFEST="$ROOT/configs/build_system_manifest.tsv"
DRY_RUN=0
RESUME=0
STATE_FILE="$ROOT/work/build_system.state"
SHOW_STATUS=0
RESET_STATE=0
RANGE_FROM=""
RANGE_UNTIL=""
TIMING_LOG="$LOGDIR/build_times.csv"
PROGRESS_LOG="$ROOT/reports/build_progress.csv"
GROUP="build_system"
CHECK=0
CHECK_ALLOW_FAIL=0
CHECK_STATUS_LOG="$ROOT/reports/build_check_status.csv"

mkdir -p "$LOGDIR" "$SRC" "$ROOT/reports"

echo "[!] Squelette : prévoyez les tarballs vérifiés dans $SRC"
echo "[!] Les commandes suivantes supposent chroot dans $LFS (après toolchain)."
echo "[i] Astuce: lancez scripts/preflight.sh avant build pour valider l'environnement."

find_tarball() {
	local base="$1"
	local ext
	for ext in tar.xz tar.gz tar.bz2 tar.zst; do
		if [ -f "$SRC/$base.$ext" ]; then
			echo "$SRC/$base.$ext"
			return 0
		fi
	done
	return 1
}

check_status_init() {
	if [ ! -f "$CHECK_STATUS_LOG" ]; then
		echo "timestamp|group|package|result|log" >"$CHECK_STATUS_LOG"
	fi
}

record_check_status() {
	local name="$1" result="$2" log="$3"
	check_status_init
	echo "$(date '+%Y-%m-%d %H:%M:%S')|$GROUP|$name|$result|$log" >>"$CHECK_STATUS_LOG"
}

build_pkg_autotools() {
	local name="$1" version="$2" cfg="$3" extra_make="$4"
	local tarball
	cd "$SRC"
	tarball=$(find_tarball "$name-$version") || {
		echo "[ERR] Tarball manquant: $SRC/$name-$version.tar.*" >&2
		return 1
	}
	[ -d "$name-$version" ] || tar xf "$tarball"
	cd "$name-$version"
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] $name-$version ./configure $cfg"
		echo "[dry-run] $name-$version make -j$JOBS"
		if [ "$CHECK" -eq 1 ]; then
			echo "[dry-run] $name-$version make check"
		fi
		[ -z "$extra_make" ] || echo "[dry-run] $name-$version $extra_make"
		echo "[dry-run] $name-$version make install"
		return
	fi
	./configure $cfg >"$LOGDIR/$name.config.log"
	make -j"$JOBS" >"$LOGDIR/$name.make.log"
	if [ "$CHECK" -eq 1 ]; then
		if ! make check >"$LOGDIR/$name.check.log" 2>&1; then
			if [ "$CHECK_ALLOW_FAIL" -eq 1 ]; then
				record_check_status "$name" "fail_ignored" "$LOGDIR/$name.check.log"
				echo "[WARN] Tests en echec pour $name (ignore)" >&2
			else
				record_check_status "$name" "fail" "$LOGDIR/$name.check.log"
				echo "[ERR] Tests en echec pour $name" >&2
				return 1
			fi
		else
			record_check_status "$name" "ok" "$LOGDIR/$name.check.log"
		fi
	fi
	[ -z "$extra_make" ] || eval "$extra_make"
	make install >"$LOGDIR/$name.install.log"
}

build_pkg_makeonly() {
	local name="$1" version="$2" extra_make="$3"
	local tarball
	cd "$SRC"
	tarball=$(find_tarball "$name-$version") || {
		echo "[ERR] Tarball manquant: $SRC/$name-$version.tar.*" >&2
		return 1
	}
	[ -d "$name-$version" ] || tar xf "$tarball"
	cd "$name-$version"
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] $name-$version make -j$JOBS"
		if [ "$CHECK" -eq 1 ]; then
			echo "[dry-run] $name-$version make check"
		fi
		[ -z "$extra_make" ] || echo "[dry-run] $name-$version $extra_make"
		echo "[dry-run] $name-$version make install"
		return
	fi
	make -j"$JOBS" >"$LOGDIR/$name.make.log"
	if [ "$CHECK" -eq 1 ]; then
		if ! make check >"$LOGDIR/$name.check.log" 2>&1; then
			if [ "$CHECK_ALLOW_FAIL" -eq 1 ]; then
				record_check_status "$name" "fail_ignored" "$LOGDIR/$name.check.log"
				echo "[WARN] Tests en echec pour $name (ignore)" >&2
			else
				record_check_status "$name" "fail" "$LOGDIR/$name.check.log"
				echo "[ERR] Tests en echec pour $name" >&2
				return 1
			fi
		else
			record_check_status "$name" "ok" "$LOGDIR/$name.check.log"
		fi
	fi
	[ -z "$extra_make" ] || eval "$extra_make"
	make install >"$LOGDIR/$name.install.log"
}

build_pkg() {
	local name="$1" version="$2" cfg="$3" extra_make="$4" build_type="$5"
	case "$build_type" in
		""|autotools)
			build_pkg_autotools "$name" "$version" "$cfg" "$extra_make" || return 1
			;;
		makeonly)
			build_pkg_makeonly "$name" "$version" "$extra_make" || return 1
			;;
		*)
			echo "[ERR] Type build inconnu pour $name: $build_type" >&2
			return 1
			;;
	esac
}

trim() {
	printf '%s' "$1" | xargs
}

should_skip() {
	local name="$1"
	if [ "$RESUME" -eq 1 ] && [ -f "$STATE_FILE" ]; then
		grep -Fxq "$name" "$STATE_FILE"
		return
	fi
	return 1
}

record_state() {
	local name="$1"
	if [ "$DRY_RUN" -eq 1 ]; then
		return
	fi
	mkdir -p "$(dirname "$STATE_FILE")"
	echo "$name" >>"$STATE_FILE"
}

timing_init() {
	if [ ! -f "$TIMING_LOG" ]; then
		echo "package,version,build_type,start,end,duration_sec,status" >"$TIMING_LOG"
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
	local name="$1" version="$2" build_type="$3" status_label="$4" duration="$5"
	progress_init
	echo "$(date '+%Y-%m-%d %H:%M:%S'),$GROUP,$name,$version,${build_type:-autotools},$status_label,$duration" >>"$PROGRESS_LOG"
}

build_with_timing() {
	local name="$1" version="$2" cfg="$3" extra_make="$4" build_type="$5"
	local start end duration status_label
	timing_init
	start=$(date +%s)
	set +e
	build_pkg "$name" "$version" "$cfg" "$extra_make" "$build_type"
	local status=$?
	set -e
	end=$(date +%s)
	duration=$((end - start))
	if [ "$DRY_RUN" -eq 1 ]; then
		status_label="dry-run"
	elif [ "$status" -eq 0 ]; then
		status_label="ok"
	else
		status_label="fail"
	fi
	echo "$name,$version,${build_type:-autotools},$start,$end,$duration,$status_label" >>"$TIMING_LOG"
	record_progress "$name" "$version" "$build_type" "$status_label" "$duration"
	return "$status"
}

manifest_names() {
	awk -F'|' 'NF && $1 !~ /^#/ {gsub(/^ +| +$/, "", $1); print $1}' "$MANIFEST"
}

show_status() {
	local total completed pending
	total=$(manifest_names | wc -l | tr -d ' ')
	if [ -f "$STATE_FILE" ]; then
		completed=$(sort -u "$STATE_FILE" | wc -l | tr -d ' ')
	else
		completed=0
	fi
	pending=$(manifest_names | while IFS= read -r name; do
		if [ -f "$STATE_FILE" ] && grep -Fxq "$name" "$STATE_FILE"; then
			continue
		fi
		echo "$name"
	done)
	echo "manifest: $MANIFEST"
	echo "state: $STATE_FILE"
	echo "total: $total"
	echo "done: $completed"
	echo "pending:"
	if [ -n "$pending" ]; then
		echo "$pending"
	else
		echo "none"
	fi
}

reset_state() {
	if [ -f "$STATE_FILE" ]; then
		rm -f "$STATE_FILE"
		echo "[i] state reset: $STATE_FILE"
	else
		echo "[i] state absent: $STATE_FILE"
	fi
}

run_manifest_entry() {
	local name="$1"
	local line
	local found=0
	while IFS= read -r line || [ -n "$line" ]; do
		case "$line" in
			""|\#*) continue ;;
		esac
		IFS='|' read -r raw_name raw_version raw_cfg raw_extra raw_type <<<"$line"
		raw_name=$(trim "$raw_name")
		if [ "$raw_name" != "$name" ]; then
			continue
		fi
		found=1
		raw_version=$(trim "$raw_version")
		raw_cfg=$(trim "$raw_cfg")
		raw_extra=$(trim "$raw_extra")
		raw_type=$(trim "$raw_type")
		if should_skip "$raw_name"; then
			echo "[skip] $raw_name deja marque dans $STATE_FILE"
			record_progress "$raw_name" "$raw_version" "$raw_type" "skip" "0"
			break
		fi
		if ! build_with_timing "$raw_name" "$raw_version" "$raw_cfg" "$raw_extra" "$raw_type"; then
			exit 1
		fi
		record_state "$raw_name"
		break
	done <"$MANIFEST"
	if [ "$found" -eq 0 ]; then
		echo "[ERR] Package introuvable dans le manifest: $name" >&2
		exit 1
	fi
}

run_manifest_all() {
	local line
	local started=0
	local found_from=0
	local found_until=0
	if [ -z "$RANGE_FROM" ]; then
		started=1
		found_from=1
	fi
	while IFS= read -r line || [ -n "$line" ]; do
		case "$line" in
			""|\#*) continue ;;
		esac
		IFS='|' read -r raw_name raw_version raw_cfg raw_extra raw_type <<<"$line"
		raw_name=$(trim "$raw_name")
		raw_version=$(trim "$raw_version")
		raw_cfg=$(trim "$raw_cfg")
		raw_extra=$(trim "$raw_extra")
		raw_type=$(trim "$raw_type")
		if [ "$started" -eq 0 ] && [ "$raw_name" = "$RANGE_FROM" ]; then
			started=1
			found_from=1
		fi
		if [ "$started" -eq 0 ]; then
			continue
		fi
		if should_skip "$raw_name"; then
			echo "[skip] $raw_name deja marque dans $STATE_FILE"
			record_progress "$raw_name" "$raw_version" "$raw_type" "skip" "0"
			continue
		fi
		if ! build_with_timing "$raw_name" "$raw_version" "$raw_cfg" "$raw_extra" "$raw_type"; then
			exit 1
		fi
		record_state "$raw_name"
		if [ -n "$RANGE_UNTIL" ] && [ "$raw_name" = "$RANGE_UNTIL" ]; then
			found_until=1
			break
		fi
	done <"$MANIFEST"
	if [ "$found_from" -eq 0 ]; then
		echo "[ERR] --from introuvable dans le manifest: $RANGE_FROM" >&2
		exit 1
	fi
	if [ -n "$RANGE_UNTIL" ] && [ "$found_until" -eq 0 ]; then
		echo "[ERR] --until introuvable dans le manifest: $RANGE_UNTIL" >&2
		exit 1
	fi
}

list_manifest() {
	awk -F'|' 'NF && $1 !~ /^#/ {gsub(/^ +| +$/, "", $1); gsub(/^ +| +$/, "", $2); gsub(/^ +| +$/, "", $5); printf "%-12s %-8s %s\n", $1, $2, $5}' "$MANIFEST"
}

usage() {
	cat <<EOF
Usage: $0 [--dry-run] [--check] [--check-allow-fail] [--resume] [--status] [--reset-state] [--from <pkg>] [--until <pkg>] [--manifest <file>] [--state <file>] {list|coreutils|bash|procps|pkg <name>|all}
EOF
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
		--dry-run) DRY_RUN=1; shift ;;
		--check) CHECK=1; shift ;;
		--check-allow-fail) CHECK_ALLOW_FAIL=1; shift ;;
		--resume) RESUME=1; shift ;;
		--status) SHOW_STATUS=1; shift ;;
		--reset-state) RESET_STATE=1; shift ;;
		--from) RANGE_FROM="$2"; shift 2 ;;
		--until) RANGE_UNTIL="$2"; shift 2 ;;
		--manifest) MANIFEST="$2"; shift 2 ;;
		--state) STATE_FILE="$2"; shift 2 ;;
		-h|--help) usage ;;
		--) shift; break ;;
		*) break ;;
	esac
done

if [ "$RESET_STATE" -eq 1 ]; then
	reset_state
fi

if [ "$SHOW_STATUS" -eq 1 ] && [ -n "${1:-}" ]; then
	show_status
fi

if [ "$SHOW_STATUS" -eq 1 ] && [ -z "${1:-}" ]; then
	show_status
	exit 0
fi

if [ "$RESET_STATE" -eq 1 ] && [ -z "${1:-}" ]; then
	exit 0
fi

case "${1:-}" in
	list)
		list_manifest
		;;
	coreutils)
		run_manifest_entry coreutils
		;;
	bash)
		run_manifest_entry bash
		;;
	procps)
		run_manifest_entry procps-ng
		;;
	pkg)
		[ -n "${2:-}" ] || usage
		run_manifest_entry "$2"
		;;
	all)
		run_manifest_all
		;;
	*)
		usage
		;;
esac
