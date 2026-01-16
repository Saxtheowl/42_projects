#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
STATS_TXT="$REPORT_DIR/build_summary_alerts_stats.txt"
TREND_TXT="$REPORT_DIR/build_summary_alerts_stats_trend.txt"
DELTA_TXT="$REPORT_DIR/build_summary_alerts_stats_delta.txt"
ROLLUP_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
ROLLUP_SCORE_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_report.txt"

usage() {
	cat <<EOF
Usage: $0 [--stats <file>] [--trend <file>] [--delta <file>] [--rollup <file>] [--rollup-score <file>] [--out <file>]

Resume stats alertes (stats + trend + delta).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--stats) STATS_TXT="$2"; shift 2 ;;
		--trend) TREND_TXT="$2"; shift 2 ;;
		--delta) DELTA_TXT="$2"; shift 2 ;;
		--rollup) ROLLUP_TXT="$2"; shift 2 ;;
		--rollup-score) ROLLUP_SCORE_TXT="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "stats: $STATS_TXT"
	echo "trend: $TREND_TXT"
	echo "delta: $DELTA_TXT"
	echo "rollup: $ROLLUP_TXT"
	echo "rollup_score: $ROLLUP_SCORE_TXT"
	echo ""
} >"$OUT_TXT"

missing=0
for file in "$STATS_TXT" "$TREND_TXT" "$DELTA_TXT"; do
	if [ ! -f "$file" ]; then
		echo "missing: $file" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$missing" -gt 0 ]; then
	echo "result: missing_inputs" >>"$OUT_TXT"
	exit 0
fi

get_value() {
	local file="$1" key="$2"
	grep -E "^${key}:" "$file" | head -n 1 | awk '{print $2}'
}

alerts_total=$(get_value "$STATS_TXT" "alerts_total")
bundle_score=$(get_value "$STATS_TXT" "bundle_score")
alert_stats_result=$(get_value "$STATS_TXT" "result")

trend_avg_alerts=$(get_value "$TREND_TXT" "avg_alerts")
trend_avg_score=$(get_value "$TREND_TXT" "avg_bundle_score")
trend_warn=$(get_value "$TREND_TXT" "warn")
trend_result=$(get_value "$TREND_TXT" "result")

alerts_delta=$(get_value "$DELTA_TXT" "alerts_delta")
score_delta=$(get_value "$DELTA_TXT" "score_delta")
delta_result=$(get_value "$DELTA_TXT" "result")

alerts_total="${alerts_total:-0}"
bundle_score="${bundle_score:-0}"
alert_stats_result="${alert_stats_result:-unknown}"
trend_avg_alerts="${trend_avg_alerts:-0}"
trend_avg_score="${trend_avg_score:-0}"
trend_warn="${trend_warn:-0}"
trend_result="${trend_result:-unknown}"
alerts_delta="${alerts_delta:-0}"
score_delta="${score_delta:-0}"
delta_result="${delta_result:-unknown}"

rollup_entries="0"
rollup_window="0"
rollup_delta_alerts="0"
rollup_delta_score="0"
rollup_result="missing"
if [ -f "$ROLLUP_TXT" ]; then
	rollup_entries=$(get_value "$ROLLUP_TXT" "entries")
	rollup_window=$(get_value "$ROLLUP_TXT" "window")
	rollup_delta_alerts=$(get_value "$ROLLUP_TXT" "delta_alerts")
	rollup_delta_score=$(get_value "$ROLLUP_TXT" "delta_score")
	rollup_result=$(get_value "$ROLLUP_TXT" "result")
fi

rollup_score="0"
rollup_score_result="missing"
if [ -f "$ROLLUP_SCORE_TXT" ]; then
	rollup_score=$(get_value "$ROLLUP_SCORE_TXT" "score")
	rollup_score_result=$(get_value "$ROLLUP_SCORE_TXT" "result")
fi

{
	echo "alerts_total: $alerts_total"
	echo "bundle_score: $bundle_score"
	echo "stats_result: $alert_stats_result"
	echo "trend_avg_alerts: $trend_avg_alerts"
	echo "trend_avg_score: $trend_avg_score"
	echo "trend_warn: $trend_warn"
	echo "trend_result: $trend_result"
	echo "alerts_delta: $alerts_delta"
	echo "score_delta: $score_delta"
	echo "delta_result: $delta_result"
	echo "rollup_entries: ${rollup_entries:-0}"
	echo "rollup_window: ${rollup_window:-0}"
	echo "rollup_delta_alerts: ${rollup_delta_alerts:-0}"
	echo "rollup_delta_score: ${rollup_delta_score:-0}"
	echo "rollup_result: ${rollup_result:-unknown}"
	echo "rollup_score: ${rollup_score:-0}"
	echo "rollup_score_result: ${rollup_score_result:-unknown}"
} >>"$OUT_TXT"

result="ok"
if [ "$alert_stats_result" != "ok" ] || [ "$trend_result" != "ok" ] || [ "$delta_result" != "ok" ]; then
	result="warn"
fi

echo "result: $result" >>"$OUT_TXT"

echo "[OK] Build summary alerts stats report generated: $OUT_TXT"
