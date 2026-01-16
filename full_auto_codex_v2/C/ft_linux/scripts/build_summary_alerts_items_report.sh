#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
ITEMS_TXT="$REPORT_DIR/build_summary_alerts_items.txt"
ITEMS_JSON="$REPORT_DIR/build_summary_alerts_items.json"
TREND_TXT="$REPORT_DIR/build_summary_alerts_items_trend.txt"
DELTA_TXT="$REPORT_DIR/build_summary_alerts_items_delta.txt"
OUT_TXT="$REPORT_DIR/build_summary_alerts_items_report.txt"

usage() {
	cat <<EOF
Usage: $0 [--items <file>] [--items-json <file>] [--trend <file>] [--delta <file>] [--out <file>]

Resume items alertes (etat, trend, delta).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--items) ITEMS_TXT="$2"; shift 2 ;;
		--items-json) ITEMS_JSON="$2"; shift 2 ;;
		--trend) TREND_TXT="$2"; shift 2 ;;
		--delta) DELTA_TXT="$2"; shift 2 ;;
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
	echo "build_summary_alerts_items_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "items: $ITEMS_TXT"
	echo "items_json: $ITEMS_JSON"
	echo "trend: $TREND_TXT"
	echo "delta: $DELTA_TXT"
	echo ""
} >"$OUT_TXT"

missing=0
for file in "$ITEMS_TXT" "$TREND_TXT" "$DELTA_TXT"; do
	if [ ! -f "$file" ]; then
		echo "missing: $file" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$missing" -gt 0 ]; then
	echo "result: missing_inputs" >>"$OUT_TXT"
	exit 0
fi

total_items=$(grep -E '^total_items:' "$ITEMS_TXT" | head -n 1 | awk '{print $2}')
unique_items=$(grep -E '^unique_items:' "$ITEMS_TXT" | head -n 1 | awk '{print $2}')
items_mode=$(grep -E '^items_mode:' "$ITEMS_TXT" | head -n 1 | awk '{print $2}')
top_line=$(grep -E '^top_items:' -A1 "$ITEMS_TXT" | tail -n 1 | sed 's/^- //')

trend_avg_total=$(grep -E '^avg_total_items:' "$TREND_TXT" | head -n 1 | awk '{print $2}')
trend_avg_unique=$(grep -E '^avg_unique_items:' "$TREND_TXT" | head -n 1 | awk '{print $2}')
trend_warn=$(grep -E '^warn:' "$TREND_TXT" | head -n 1 | awk '{print $2}')
trend_result=$(grep -E '^result:' "$TREND_TXT" | head -n 1 | awk '{print $2}')

delta_total=$(grep -E '^delta_total_items:' "$DELTA_TXT" | head -n 1 | awk '{print $2}')
delta_unique=$(grep -E '^delta_unique_items:' "$DELTA_TXT" | head -n 1 | awk '{print $2}')
delta_result=$(grep -E '^result:' "$DELTA_TXT" | head -n 1 | awk '{print $2}')
delta_top_changed=$(grep -E '^top_text_changed:' "$DELTA_TXT" | head -n 1 | awk '{print $2}')
delta_mode_changed=$(grep -E '^items_mode_changed:' "$DELTA_TXT" | head -n 1 | awk '{print $2}')

{
	echo "items_total: ${total_items:-0}"
	echo "items_unique: ${unique_items:-0}"
	echo "items_mode: ${items_mode:-unknown}"
	echo "items_top: ${top_line:-none}"
	echo "trend_avg_total: ${trend_avg_total:-0}"
	echo "trend_avg_unique: ${trend_avg_unique:-0}"
	echo "trend_warn: ${trend_warn:-0}"
	echo "trend_result: ${trend_result:-unknown}"
	echo "delta_total: ${delta_total:-0}"
	echo "delta_unique: ${delta_unique:-0}"
	echo "delta_result: ${delta_result:-unknown}"
	echo "delta_top_changed: ${delta_top_changed:-false}"
	echo "delta_mode_changed: ${delta_mode_changed:-false}"
} >>"$OUT_TXT"

result="ok"
if [ "${items_mode:-unknown}" != "present" ] || [ "${trend_result:-unknown}" = "warn" ] || [ "${delta_result:-unknown}" = "warn" ]; then
	result="warn"
fi
if [ "${delta_top_changed:-false}" = "true" ] || [ "${delta_mode_changed:-false}" = "true" ]; then
	result="warn"
fi
echo "result: $result" >>"$OUT_TXT"

echo "[OK] Build summary alerts items report generated: $OUT_TXT"
