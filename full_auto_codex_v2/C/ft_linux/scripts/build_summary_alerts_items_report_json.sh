#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/build_summary_alerts_items_report.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_items_report.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts_items_report_json.txt"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--json <file>] [--out <file>]

Exporte un JSON a partir du rapport build_summary_alerts_items_report.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--in) IN_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
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
	echo "build_summary_alerts_items_report_json generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "in: $IN_TXT"
	echo "json: $OUT_JSON"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TXT" ]; then
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$IN_TXT\","
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	echo "result: missing_report" >>"$OUT_TXT"
	echo "missing_report: $IN_TXT" >>"$OUT_TXT"
	exit 0
fi

get_value() {
	local key="$1"
	grep -E "^${key}:" "$IN_TXT" | head -n 1 | awk '{print $2}'
}

get_value_rest() {
	local key="$1"
	grep -E "^${key}:" "$IN_TXT" | head -n 1 | cut -d' ' -f2-
}

items_total=$(get_value "items_total")
items_unique=$(get_value "items_unique")
items_mode=$(get_value "items_mode")
items_top=$(get_value_rest "items_top")
items_top="${items_top#items_top: }"
items_top=$(printf '%s' "$items_top" | sed "s/\"/'/g")
trend_avg_total=$(get_value "trend_avg_total")
trend_avg_unique=$(get_value "trend_avg_unique")
trend_warn=$(get_value "trend_warn")
trend_result=$(get_value "trend_result")
delta_total=$(get_value "delta_total")
delta_unique=$(get_value "delta_unique")
delta_result=$(get_value "delta_result")
delta_top_changed=$(get_value "delta_top_changed")
delta_mode_changed=$(get_value "delta_mode_changed")
result=$(get_value "result")

items_total="${items_total:-0}"
items_unique="${items_unique:-0}"
items_mode="${items_mode:-unknown}"
if [ -z "$items_top" ]; then
	items_top="none"
fi
trend_avg_total="${trend_avg_total:-0}"
trend_avg_unique="${trend_avg_unique:-0}"
trend_warn="${trend_warn:-0}"
trend_result="${trend_result:-unknown}"
delta_total="${delta_total:-0}"
delta_unique="${delta_unique:-0}"
delta_result="${delta_result:-unknown}"
delta_top_changed="${delta_top_changed:-false}"
delta_mode_changed="${delta_mode_changed:-false}"
result="${result:-unknown}"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$IN_TXT\","
	echo "  \"items_total\": $items_total,"
	echo "  \"items_unique\": $items_unique,"
	echo "  \"items_mode\": \"$items_mode\","
	echo "  \"items_top\": \"${items_top}\","
	echo "  \"trend_avg_total\": $trend_avg_total,"
	echo "  \"trend_avg_unique\": $trend_avg_unique,"
	echo "  \"trend_warn\": $trend_warn,"
	echo "  \"trend_result\": \"$trend_result\","
	echo "  \"delta_total\": $delta_total,"
	echo "  \"delta_unique\": $delta_unique,"
	echo "  \"delta_result\": \"$delta_result\","
	echo "  \"delta_top_changed\": \"$delta_top_changed\","
	echo "  \"delta_mode_changed\": \"$delta_mode_changed\","
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build summary alerts items report JSON generated: $OUT_TXT"
