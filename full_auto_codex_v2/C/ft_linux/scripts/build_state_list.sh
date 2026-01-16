#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SNAP_DIR="$REPORT_DIR/state_snapshots"
OUT_TXT="$REPORT_DIR/build_state_snapshots.txt"

usage() {
	cat <<EOF
Usage: $0 [--dir <snapshots_dir>] [--out <file>]

Liste les snapshots de state (dates + chemins).
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
	echo "build_state_snapshots generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "dir: $SNAP_DIR"
	echo ""
} >"$OUT_TXT"

if [ ! -d "$SNAP_DIR" ]; then
	echo "result: missing_dir" >>"$OUT_TXT"
	echo "missing snapshots dir" >>"$OUT_TXT"
	exit 0
fi

list=$(ls -1 "$SNAP_DIR" 2>/dev/null || true)
if [ -z "$list" ]; then
	echo "result: empty" >>"$OUT_TXT"
	echo "no snapshots" >>"$OUT_TXT"
	exit 0
fi

echo "snapshots:" >>"$OUT_TXT"
for snap in $list; do
	echo "- $snap" >>"$OUT_TXT"
done

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build state snapshots listed: $OUT_TXT"
