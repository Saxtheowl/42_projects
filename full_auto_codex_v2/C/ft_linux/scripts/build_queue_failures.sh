#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV="$REPORT_DIR/build_queue.csv"
OUT_TXT="$REPORT_DIR/build_queue_failures.txt"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>]

Liste les echecs/timeout du build_queue.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) CSV="$2"; shift 2 ;;
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
	echo "build_queue_failures generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

fail_list=$(awk -F',' 'NR>1 && ($5=="fail" || $5=="timeout") {print $0}' "$CSV")
if [ -z "$fail_list" ]; then
	echo "result: ok" >>"$OUT_TXT"
	echo "no failures" >>"$OUT_TXT"
	exit 0
fi

echo "result: warn" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"
echo "failures:" >>"$OUT_TXT"
printf '%s\n' "$fail_list" >>"$OUT_TXT"

echo "[OK] Build queue failures generated: $OUT_TXT"
