#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SNAP_DIR="$REPORT_DIR/check_snapshots"
OUT_TXT="$REPORT_DIR/build_check_snapshot_list.txt"

usage() {
	cat <<EOF
Usage: $0 [--dir <dir>] [--out <file>]

Liste les snapshots build_check_status.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--dir) SNAP_DIR="$2"; shift 2 ;;
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
	echo "build_check_snapshot_list generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "dir: $SNAP_DIR"
	echo ""
} >"$OUT_TXT"

if [ ! -d "$SNAP_DIR" ]; then
	echo "result: missing_dir" >>"$OUT_TXT"
	echo "missing_dir: $SNAP_DIR" >>"$OUT_TXT"
	echo "[OK] Build check snapshot list generated: $OUT_TXT"
	exit 0
fi

count=0
total_lines=0
newest=""
while IFS= read -r file; do
	count=$((count + 1))
	lines=$(wc -l <"$file" | awk '{print $1}')
	total_lines=$((total_lines + lines))
	echo "snapshot: $file lines=$lines" >>"$OUT_TXT"
	newest="$file"
done < <(ls -1 "$SNAP_DIR"/*.csv 2>/dev/null | sort)

if [ "$count" -eq 0 ]; then
	echo "result: empty" >>"$OUT_TXT"
else
	echo "result: ok" >>"$OUT_TXT"
fi

echo "count: $count" >>"$OUT_TXT"
echo "total_lines: $total_lines" >>"$OUT_TXT"
if [ -n "$newest" ]; then
	newest_lines=$(wc -l <"$newest" | awk '{print $1}')
	echo "newest: $newest lines=$newest_lines" >>"$OUT_TXT"
fi
echo "[OK] Build check snapshot list generated: $OUT_TXT"
