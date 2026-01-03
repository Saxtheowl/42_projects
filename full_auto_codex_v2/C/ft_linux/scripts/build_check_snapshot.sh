#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV_FILE="$REPORT_DIR/build_check_status.csv"
SNAP_DIR="$REPORT_DIR/check_snapshots"
OUT_TXT="$REPORT_DIR/build_check_snapshot.txt"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>] [--dir <dir>]

Snapshot du CSV build_check_status vers reports/check_snapshots.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) CSV_FILE="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--dir) SNAP_DIR="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR" "$SNAP_DIR"

{
	echo "build_check_snapshot generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo "dir: $SNAP_DIR"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV_FILE" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "missing_csv: $CSV_FILE" >>"$OUT_TXT"
	echo "[OK] Build check snapshot generated: $OUT_TXT"
	exit 0
fi

ts=$(date '+%Y%m%d_%H%M%S')
snap="$SNAP_DIR/check_status_$ts.csv"
cp "$CSV_FILE" "$snap"
lines=$(wc -l <"$snap" | awk '{print $1}')

echo "snapshot: $snap" >>"$OUT_TXT"
echo "lines: $lines" >>"$OUT_TXT"
echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build check snapshot generated: $OUT_TXT"
