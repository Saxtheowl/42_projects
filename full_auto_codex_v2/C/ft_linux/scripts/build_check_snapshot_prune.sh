#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SNAP_DIR="$REPORT_DIR/check_snapshots"
OUT_TXT="$REPORT_DIR/build_check_snapshot_prune.txt"
KEEP=10
APPLY=0

usage() {
	cat <<EOF
Usage: $0 [--dir <dir>] [--keep <n>] [--apply] [--out <file>]

Garde les N derniers snapshots checks.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--dir) SNAP_DIR="$2"; shift 2 ;;
		--keep) KEEP="$2"; shift 2 ;;
		--apply) APPLY=1; shift ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_check_snapshot_prune generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "dir: $SNAP_DIR"
	echo "keep: $KEEP"
	echo "apply: $APPLY"
	echo ""
} >"$OUT_TXT"

if [ ! -d "$SNAP_DIR" ]; then
	echo "result: missing_dir" >>"$OUT_TXT"
	echo "missing_dir: $SNAP_DIR" >>"$OUT_TXT"
	echo "[OK] Build check snapshot prune generated: $OUT_TXT"
	exit 0
fi

mapfile -t files < <(ls -1 "$SNAP_DIR"/*.csv 2>/dev/null | sort)
count=${#files[@]}
if [ "$count" -eq 0 ]; then
	echo "result: empty" >>"$OUT_TXT"
	echo "count: 0" >>"$OUT_TXT"
	echo "[OK] Build check snapshot prune generated: $OUT_TXT"
	exit 0
fi

	echo "count: $count" >>"$OUT_TXT"
	if [ "$count" -le "$KEEP" ]; then
		echo "result: ok" >>"$OUT_TXT"
		echo "prune_candidates: 0" >>"$OUT_TXT"
		echo "after: $count" >>"$OUT_TXT"
		echo "[OK] Build check snapshot prune generated: $OUT_TXT"
		exit 0
	fi

prune_candidates=$((count - KEEP))
echo "prune_candidates: $prune_candidates" >>"$OUT_TXT"

if [ "$APPLY" -eq 1 ]; then
	for ((i=0; i<prune_candidates; i++)); do
		echo "prune: ${files[$i]}" >>"$OUT_TXT"
		rm -f "${files[$i]}"
	done
	echo "applied: yes" >>"$OUT_TXT"
	after=$(ls -1 "$SNAP_DIR"/*.csv 2>/dev/null | wc -l | awk '{print $1}')
	echo "after: $after" >>"$OUT_TXT"
else
	for ((i=0; i<prune_candidates; i++)); do
		echo "prune: ${files[$i]}" >>"$OUT_TXT"
	done
	echo "applied: no" >>"$OUT_TXT"
fi

echo "result: warn" >>"$OUT_TXT"
echo "[OK] Build check snapshot prune generated: $OUT_TXT"
