#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV_FILE="$REPORT_DIR/build_summary_bundle_index_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_bundle_index_history_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>]

Valide le CSV build_summary_bundle_index_history.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) CSV_FILE="$2"; shift 2 ;;
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
	echo "build_summary_bundle_index_history_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV_FILE" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

header=$(head -n 1 "$CSV_FILE" | tr -d '\r')
missing=0

if [ "$header" != "generated,files,result" ]; then
	echo "invalid_header: $header" >>"$OUT_TXT"
	missing=$((missing + 1))
fi

entries=$(tail -n +2 "$CSV_FILE" | grep -c '.')
echo "entries: $entries" >>"$OUT_TXT"

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary bundle index history validate generated: $OUT_TXT"
