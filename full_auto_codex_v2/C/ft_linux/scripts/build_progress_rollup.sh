#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_progress_rollup.txt"
PROGRESS_LOG="$REPORT_DIR/build_progress.csv"

SYSTEM_MANIFEST="$ROOT/configs/build_system_manifest.tsv"
MINI_MANIFEST="$ROOT/configs/mini_system_manifest.tsv"
SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_STATE="$ROOT/work/mini_system.state"

usage() {
	cat <<EOF
Usage: $0 [--log <file>] [--out <file>] [--system-manifest <file>] [--mini-manifest <file>]

Synthese progression par groupe (manifest/state/progress).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--log) PROGRESS_LOG="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--system-manifest) SYSTEM_MANIFEST="$2"; shift 2 ;;
		--mini-manifest) MINI_MANIFEST="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

manifest_count() {
	local manifest="$1"
	awk -F'|' 'NF && $1 !~ /^#/ {count++} END {print count+0}' "$manifest"
}

state_count() {
	local state="$1"
	if [ -f "$state" ]; then
		sort -u "$state" | wc -l | tr -d ' '
	else
		echo 0
	fi
}

progress_count() {
	local group="$1" status="$2"
	if [ -f "$PROGRESS_LOG" ]; then
		awk -F',' -v g="$group" -v s="$status" 'NR>1 && $2==g && $6==s {count++} END {print count+0}' "$PROGRESS_LOG"
	else
		echo 0
	fi
}

{
	echo "build_progress_rollup generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "progress_log: $PROGRESS_LOG"
	echo ""
} >"$OUT_TXT"

system_total=$(manifest_count "$SYSTEM_MANIFEST")
mini_total=$(manifest_count "$MINI_MANIFEST")
system_done=$(state_count "$SYSTEM_STATE")
mini_done=$(state_count "$MINI_STATE")

sys_ok=$(progress_count "build_system" "ok")
sys_fail=$(progress_count "build_system" "fail")
sys_skip=$(progress_count "build_system" "skip")
sys_dry=$(progress_count "build_system" "dry-run")

mini_ok=$(progress_count "mini_system" "ok")
mini_fail=$(progress_count "mini_system" "fail")
mini_skip=$(progress_count "mini_system" "skip")
mini_dry=$(progress_count "mini_system" "dry-run")

{
	echo "[build_system]"
	echo "manifest_total: $system_total"
	echo "state_done: $system_done"
	echo "progress_ok: $sys_ok"
	echo "progress_fail: $sys_fail"
	echo "progress_skip: $sys_skip"
	echo "progress_dry_run: $sys_dry"
	echo ""
	echo "[mini_system]"
	echo "manifest_total: $mini_total"
	echo "state_done: $mini_done"
	echo "progress_ok: $mini_ok"
	echo "progress_fail: $mini_fail"
	echo "progress_skip: $mini_skip"
	echo "progress_dry_run: $mini_dry"
	echo ""
} >>"$OUT_TXT"

if [ "$sys_fail" -eq 0 ] && [ "$mini_fail" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build progress rollup generated: $OUT_TXT"
