#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_report.txt"
OUT_MD="$REPORT_DIR/build_summary_alerts_stats_report.md"

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport Markdown pour les stats alertes.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
		--out) OUT_MD="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ ! -f "$REPORT_FILE" ]; then
	{
		echo "# Build Summary Alerts Stats"
		echo ""
		echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
		echo ""
		echo "Result: missing"
	} >"$OUT_MD"
	exit 0
fi

get_value() {
	local key="$1"
	grep -E "^${key}:" "$REPORT_FILE" | head -n 1 | awk '{print $2}'
}

alerts_total=$(get_value "alerts_total")
bundle_score=$(get_value "bundle_score")
stats_result=$(get_value "stats_result")
trend_avg_alerts=$(get_value "trend_avg_alerts")
trend_avg_score=$(get_value "trend_avg_score")
trend_warn=$(get_value "trend_warn")
trend_result=$(get_value "trend_result")
alerts_delta=$(get_value "alerts_delta")
score_delta=$(get_value "score_delta")
delta_result=$(get_value "delta_result")
rollup_entries=$(get_value "rollup_entries")
rollup_window=$(get_value "rollup_window")
rollup_delta_alerts=$(get_value "rollup_delta_alerts")
rollup_delta_score=$(get_value "rollup_delta_score")
rollup_result=$(get_value "rollup_result")
rollup_score=$(get_value "rollup_score")
rollup_score_result=$(get_value "rollup_score_result")
result=$(get_value "result")

alerts_total="${alerts_total:-0}"
bundle_score="${bundle_score:-0}"
stats_result="${stats_result:-unknown}"
trend_avg_alerts="${trend_avg_alerts:-0}"
trend_avg_score="${trend_avg_score:-0}"
trend_warn="${trend_warn:-0}"
trend_result="${trend_result:-unknown}"
alerts_delta="${alerts_delta:-0}"
score_delta="${score_delta:-0}"
delta_result="${delta_result:-unknown}"
rollup_entries="${rollup_entries:-0}"
rollup_window="${rollup_window:-0}"
rollup_delta_alerts="${rollup_delta_alerts:-0}"
rollup_delta_score="${rollup_delta_score:-0}"
rollup_result="${rollup_result:-unknown}"
rollup_score="${rollup_score:-0}"
rollup_score_result="${rollup_score_result:-unknown}"
result="${result:-unknown}"

{
	echo "# Build Summary Alerts Stats"
	echo ""
	echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "## Stats"
	echo "- alerts_total: $alerts_total"
	echo "- bundle_score: $bundle_score"
	echo "- result: $stats_result"
	echo ""
	echo "## Trend"
	echo "- avg_alerts: $trend_avg_alerts"
	echo "- avg_bundle_score: $trend_avg_score"
	echo "- warn: $trend_warn"
	echo "- result: $trend_result"
	echo ""
	echo "## Delta"
	echo "- alerts_delta: $alerts_delta"
	echo "- score_delta: $score_delta"
	echo "- result: $delta_result"
	echo ""
	echo "## Rollup"
	echo "- entries: $rollup_entries"
	echo "- window: $rollup_window"
	echo "- delta_alerts: $rollup_delta_alerts"
	echo "- delta_score: $rollup_delta_score"
	echo "- result: $rollup_result"
	echo ""
	echo "## Rollup Score"
	echo "- score: $rollup_score"
	echo "- result: $rollup_score_result"
	echo ""
	echo "Result: $result"
} >"$OUT_MD"

echo "[OK] Build summary alerts stats report MD generated: $OUT_MD"
