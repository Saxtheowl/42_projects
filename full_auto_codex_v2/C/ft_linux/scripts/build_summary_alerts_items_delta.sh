#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_items_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_items_delta.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_items_delta.json"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>] [--json <file>]

Compare les deux dernieres entrees alertes items (delta).
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
	echo "build_summary_alerts_items_delta generated: $(date '+%Y-%m-%d %H:%M:%S')"
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
last_total=$(printf '%s' "$last_line" | awk -F',' '{print $2}')
last_unique=$(printf '%s' "$last_line" | awk -F',' '{print $3}')
last_mode=$(printf '%s' "$last_line" | awk -F',' '{print $4}')
last_top=$(printf '%s' "$last_line" | awk -F',' '{print $5}')
last_result=$(printf '%s' "$last_line" | awk -F',' '{print $6}')

prev_generated=""
prev_total=""
prev_unique=""
prev_mode=""
prev_top=""
if [ -n "$prev_line" ]; then
	prev_generated=$(printf '%s' "$prev_line" | awk -F',' '{print $1}')
	prev_total=$(printf '%s' "$prev_line" | awk -F',' '{print $2}')
	prev_unique=$(printf '%s' "$prev_line" | awk -F',' '{print $3}')
	prev_mode=$(printf '%s' "$prev_line" | awk -F',' '{print $4}')
	prev_top=$(printf '%s' "$prev_line" | awk -F',' '{print $5}')
fi

last_total="${last_total:-0}"
last_unique="${last_unique:-0}"
prev_total="${prev_total:-0}"
prev_unique="${prev_unique:-0}"
delta_total=$((last_total - prev_total))
delta_unique=$((last_unique - prev_unique))

top_text_changed="false"
if [ -n "$prev_top" ] && [ -n "$last_top" ] && [ "$prev_top" != "$last_top" ]; then
	top_text_changed="true"
fi

items_mode_changed="false"
if [ -n "$prev_mode" ] && [ -n "$last_mode" ] && [ "$prev_mode" != "$last_mode" ]; then
	items_mode_changed="true"
fi

overall="ok"
if [ "${last_result:-unknown}" != "ok" ] || [ "${last_mode:-unknown}" != "present" ]; then
	overall="warn"
fi
if [ "$delta_total" -lt 0 ] || [ "$delta_unique" -lt 0 ]; then
	overall="warn"
fi

{
	echo "last_generated: $last_generated"
	echo "last_total_items: $last_total"
	echo "last_unique_items: $last_unique"
	echo "last_items_mode: ${last_mode:-unknown}"
	echo "last_top_text: ${last_top:-none}"
	echo "last_result: ${last_result:-unknown}"
	echo "prev_generated: $prev_generated"
	echo "prev_total_items: $prev_total"
	echo "prev_unique_items: $prev_unique"
	echo "prev_items_mode: ${prev_mode:-unknown}"
	echo "prev_top_text: ${prev_top:-none}"
	echo "delta_total_items: $delta_total"
	echo "delta_unique_items: $delta_unique"
	echo "top_text_changed: $top_text_changed"
	echo "items_mode_changed: $items_mode_changed"
	echo "result: $overall"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$HISTORY_CSV\","
	echo "  \"last\": {"
	echo "    \"generated\": \"$last_generated\","
	echo "    \"total_items\": $last_total,"
	echo "    \"unique_items\": $last_unique,"
	echo "    \"items_mode\": \"${last_mode:-unknown}\","
	echo "    \"top_text\": \"${last_top:-none}\","
	echo "    \"result\": \"${last_result:-unknown}\""
	echo "  },"
	echo "  \"previous\": {"
	echo "    \"generated\": \"$prev_generated\","
	echo "    \"total_items\": $prev_total,"
	echo "    \"unique_items\": $prev_unique,"
	echo "    \"items_mode\": \"${prev_mode:-unknown}\","
	echo "    \"top_text\": \"${prev_top:-none}\""
	echo "  },"
	echo "  \"delta_total_items\": $delta_total,"
	echo "  \"delta_unique_items\": $delta_unique,"
	echo "  \"top_text_changed\": $top_text_changed,"
	echo "  \"items_mode_changed\": $items_mode_changed,"
	echo "  \"result\": \"$overall\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts items delta generated: $OUT_TXT"
