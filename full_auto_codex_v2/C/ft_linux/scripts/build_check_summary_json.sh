#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_JSON="$REPORT_DIR/build_check_summary.json"

REPORT_FILE="$REPORT_DIR/build_check_report.txt"
STATS_FILE="$REPORT_DIR/build_check_stats.txt"
TREND_FILE="$REPORT_DIR/build_check_trend.txt"
GATE_FILE="$REPORT_DIR/build_check_gate.txt"
REGRESSIONS_FILE="$REPORT_DIR/build_check_regressions.txt"
REG_GROUPS_FILE="$REPORT_DIR/build_check_regressions_groups.txt"
REG_TRANS_FILE="$REPORT_DIR/build_check_regressions_transitions.txt"
REG_SUMMARY_FILE="$REPORT_DIR/build_check_regressions_summary.txt"

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
regressions_result=$(report_result "$REGRESSIONS_FILE")
transitions_result=$(report_result "$REG_TRANS_FILE")

regressions=$(value_from_report "$REGRESSIONS_FILE" "regressions")
recoveries=$(value_from_report "$REGRESSIONS_FILE" "recoveries")
unchanged=$(value_from_report "$REGRESSIONS_FILE" "unchanged")
reg_added=$(value_from_report "$REGRESSIONS_FILE" "added")
reg_removed=$(value_from_report "$REGRESSIONS_FILE" "removed")
reg_total=$(value_from_report "$REGRESSIONS_FILE" "total_compared")
transitions_total=$(value_from_report "$REG_TRANS_FILE" "transitions_total")
transitions_reg=$(value_from_report "$REG_TRANS_FILE" "regressions")
transitions_rec=$(value_from_report "$REG_TRANS_FILE" "recoveries")
top_transition=""
top_transition_count="0"
if [ -f "$REG_TRANS_FILE" ]; then
	IFS='|' read -r top_transition top_transition_count < <(
		awk '
			/^transition: / {
				t=$2; c=$3;
				if (c+0 >= max+0) {max=c; tt=t}
			}
			END {if (tt!="") printf "%s|%s", tt, max+0}
		' "$REG_TRANS_FILE"
	)
fi
worst_group=""; worst_rate="0"
if [ -f "$REG_GROUPS_FILE" ]; then
	IFS='|' read -r worst_group worst_rate < <(
		awk '
			/^\[group:/ {g=$0; sub(/^\[group:/,"",g); sub(/\]$/,"",g)}
			/^regression_rate:/ {
				r=$2;
				if (g!="") {
					if (r+0 >= max+0) {max=r; mg=g}
				}
				g="";
			}
			END {if (mg!="") printf "%s|%s", mg, max}
		' "$REG_GROUPS_FILE"
	)
fi

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
	echo "  \"regressions\": \"$REGRESSIONS_FILE\","
	echo "  \"regressions_groups\": \"$REG_GROUPS_FILE\","
	echo "  \"regressions_transitions\": \"$REG_TRANS_FILE\","
	echo "  \"regressions_summary\": \"$REG_SUMMARY_FILE\","
	echo "  \"result\": \"${report_result:-unknown}\","
	echo "  \"report_result\": \"${report_result:-unknown}\","
	echo "  \"stats_result\": \"${stats_result:-unknown}\","
	echo "  \"trend_result\": \"${trend_result:-unknown}\","
	echo "  \"gate_result\": \"${gate_result:-unknown}\","
	echo "  \"regressions_result\": \"${regressions_result:-unknown}\","
	echo "  \"transitions_result\": \"${transitions_result:-unknown}\","
	echo "  \"summary\": {"
	echo "    \"failures\": ${failures:-0},"
	echo "    \"ignored\": ${ignored:-0},"
	echo "    \"missing\": ${missing:-0},"
	echo "    \"total_packages\": ${total_packages:-0},"
	echo "    \"fail_rate\": ${fail_rate:-0},"
	echo "    \"ignored_rate\": ${ignored_rate:-0},"
	echo "    \"overall_severity\": ${overall_severity:-0},"
	echo "    \"coverage_rate\": ${coverage_rate:-0},"
	echo "    \"missing_rate\": ${missing_rate:-0},"
	echo "    \"regressions\": ${regressions:-0},"
	echo "    \"recoveries\": ${recoveries:-0},"
	echo "    \"unchanged\": ${unchanged:-0},"
	echo "    \"added\": ${reg_added:-0},"
	echo "    \"removed\": ${reg_removed:-0},"
	echo "    \"total_compared\": ${reg_total:-0},"
	echo "    \"worst_regression_group\": \"${worst_group}\","
	echo "    \"worst_regression_rate\": ${worst_rate:-0},"
	echo "    \"transitions_total\": ${transitions_total:-0},"
	echo "    \"transitions_regressions\": ${transitions_reg:-0},"
	echo "    \"transitions_recoveries\": ${transitions_rec:-0},"
	echo "    \"top_transition\": \"${top_transition}\","
	echo "    \"top_transition_count\": ${top_transition_count:-0}"
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
