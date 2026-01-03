#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_JSON="$REPORT_DIR/build_check_summary.json"

REPORT_FILE="$REPORT_DIR/build_check_report.txt"
STATS_FILE="$REPORT_DIR/build_check_stats.txt"
TREND_FILE="$REPORT_DIR/build_check_trend.txt"
GATE_FILE="$REPORT_DIR/build_check_gate.txt"

report_result() {
	local file="$1"
	if [ -f "$file" ]; then
		grep -E '^result:' "$file" | head -n 1 | awk '{print $2}'
	else
		echo "missing"
	fi
}

value_from_report() {
	local file="$1" key="$2"
	if [ -f "$file" ]; then
		grep -E "^${key}:" "$file" | head -n 1 | awk '{print $2}'
	fi
}

value_from_report_tail() {
	local file="$1" key="$2"
	if [ -f "$file" ]; then
		grep -E "^${key}:" "$file" | tail -n 1 | awk '{print $2}'
	fi
}

trend_last() {
	local file="$1"
	if [ -f "$file" ]; then
		awk '
			/^\[day:/ {
				gsub(/^\[day:|\]$/, "", $0);
				day=$0;
			}
			/^ok:/ {ok=$2}
			/^fail:/ {fail=$2}
			/^fail_ignored:/ {ign=$2}
			/^other:/ {other=$2}
			/^total:/ {total=$2}
			END {
				if (day!="") {
					printf "%s|%s|%s|%s|%s|%s", day, ok+0, fail+0, ign+0, other+0, total+0
				}
			}
		' "$file"
	fi
}

mkdir -p "$REPORT_DIR"

failures=$(value_from_report "$REPORT_FILE" "check_failures")
ignored=$(value_from_report "$REPORT_FILE" "check_fail_ignored")
missing=$(value_from_report "$REPORT_FILE" "check_missing")

total_packages=$(value_from_report "$STATS_FILE" "total_packages")
fail_rate=$(value_from_report "$STATS_FILE" "fail_rate")
ignored_rate=$(value_from_report "$STATS_FILE" "ignored_rate")
overall_severity=$(value_from_report "$STATS_FILE" "overall_severity")
coverage_rate=$(value_from_report_tail "$REPORT_DIR/build_check_coverage.txt" "coverage_rate")
missing_rate=$(value_from_report_tail "$REPORT_DIR/build_check_coverage.txt" "missing_rate")

gate_result=$(report_result "$GATE_FILE")
report_result=$(report_result "$REPORT_FILE")
stats_result=$(report_result "$STATS_FILE")
trend_result=$(report_result "$TREND_FILE")

trend_line="$(trend_last "$TREND_FILE")"
trend_day=""
trend_ok=0
trend_fail=0
trend_ign=0
trend_other=0
trend_total=0
if [ -n "$trend_line" ]; then
	IFS='|' read -r trend_day trend_ok trend_fail trend_ign trend_other trend_total <<<"$trend_line"
fi

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"report\": \"$REPORT_FILE\","
	echo "  \"stats\": \"$STATS_FILE\","
	echo "  \"trend\": \"$TREND_FILE\","
	echo "  \"gate\": \"$GATE_FILE\","
	echo "  \"result\": \"${report_result:-unknown}\","
	echo "  \"report_result\": \"${report_result:-unknown}\","
	echo "  \"stats_result\": \"${stats_result:-unknown}\","
	echo "  \"trend_result\": \"${trend_result:-unknown}\","
	echo "  \"gate_result\": \"${gate_result:-unknown}\","
	echo "  \"summary\": {"
	echo "    \"failures\": ${failures:-0},"
	echo "    \"ignored\": ${ignored:-0},"
	echo "    \"missing\": ${missing:-0},"
	echo "    \"total_packages\": ${total_packages:-0},"
	echo "    \"fail_rate\": ${fail_rate:-0},"
	echo "    \"ignored_rate\": ${ignored_rate:-0},"
	echo "    \"overall_severity\": ${overall_severity:-0},"
	echo "    \"coverage_rate\": ${coverage_rate:-0},"
	echo "    \"missing_rate\": ${missing_rate:-0}"
	echo "  },"
	echo "  \"trend_last\": {"
	echo "    \"day\": \"${trend_day}\","
	echo "    \"ok\": ${trend_ok:-0},"
	echo "    \"fail\": ${trend_fail:-0},"
	echo "    \"fail_ignored\": ${trend_ign:-0},"
	echo "    \"other\": ${trend_other:-0},"
	echo "    \"total\": ${trend_total:-0}"
	echo "  }"
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build check summary JSON generated: $OUT_JSON"
