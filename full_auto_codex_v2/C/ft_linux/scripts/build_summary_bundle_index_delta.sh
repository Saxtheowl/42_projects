#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_bundle_index_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_bundle_index_delta.txt"
OUT_JSON="$REPORT_DIR/build_summary_bundle_index_delta.json"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>] [--json <file>]

Compare les deux dernieres entrees bundle index (delta fichiers).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) HISTORY_CSV="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_bundle_index_delta generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $HISTORY_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

line_count=$(tail -n +2 "$HISTORY_CSV" | wc -l | tr -d ' ')
if [ "$line_count" -lt 1 ]; then
	echo "result: empty_csv" >>"$OUT_TXT"
	exit 0
fi

last_line=$(tail -n 1 "$HISTORY_CSV")
prev_line=""
if [ "$line_count" -ge 2 ]; then
	prev_line=$(tail -n 2 "$HISTORY_CSV" | head -n 1)
fi

last_generated=$(printf '%s' "$last_line" | awk -F',' '{print $1}')
last_files=$(printf '%s' "$last_line" | awk -F',' '{print $2}')
last_result=$(printf '%s' "$last_line" | awk -F',' '{print $3}')

prev_generated=""
prev_files=""
if [ -n "$prev_line" ]; then
	prev_generated=$(printf '%s' "$prev_line" | awk -F',' '{print $1}')
	prev_files=$(printf '%s' "$prev_line" | awk -F',' '{print $2}')
fi

last_files="${last_files:-0}"
prev_files="${prev_files:-0}"
delta=$((last_files - prev_files))

overall="ok"
if [ "${last_result:-unknown}" != "ok" ] || [ "$delta" -lt 0 ]; then
	overall="warn"
fi

{
	echo "last_generated: $last_generated"
	echo "last_files: $last_files"
	echo "last_result: ${last_result:-unknown}"
	echo "prev_generated: $prev_generated"
	echo "prev_files: $prev_files"
	echo "delta_files: $delta"
	echo "result: $overall"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$HISTORY_CSV\","
	echo "  \"last\": {"
	echo "    \"generated\": \"$last_generated\","
	echo "    \"files\": $last_files,"
	echo "    \"result\": \"${last_result:-unknown}\""
	echo "  },"
	echo "  \"previous\": {"
	echo "    \"generated\": \"$prev_generated\","
	echo "    \"files\": $prev_files"
	echo "  },"
	echo "  \"delta_files\": $delta,"
	echo "  \"result\": \"$overall\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary bundle index delta generated: $OUT_TXT"
