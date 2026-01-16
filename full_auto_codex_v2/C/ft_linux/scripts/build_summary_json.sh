#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_JSON="$REPORT_DIR/build_summary.json"

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

value_from_section() {
	local file="$1" section="$2" key="$3"
	if [ -f "$file" ]; then
		awk -v sec="[$section]" -v key="$key" '
			$0==sec {in=1; next}
			in && /^\[.*\]/ {in=0}
			in && $1==key":" {print $2; exit}
		' "$file"
	fi
}

value_from_json_string() {
	local file="$1" key="$2"
	if [ -f "$file" ]; then
		grep -E "\"$key\"" "$file" | head -n 1 | awk -F'"' '{print $4}'
	fi
}

value_from_json_number() {
	local file="$1" key="$2"
	if [ -f "$file" ]; then
		grep -E "\"$key\"" "$file" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,'
	fi
}

csv_entries() {
	local file="$1"
	if [ -f "$file" ]; then
		tail -n +2 "$file" | wc -l | tr -d ' '
	fi
}

status_assessment="$REPORT_DIR/status_assessment.txt"
build_health="$REPORT_DIR/build_health_report.txt"
build_gate="$REPORT_DIR/build_gate.txt"
build_gate_trend="$REPORT_DIR/build_gate_trend.txt"
build_gate_validate="$REPORT_DIR/build_gate_validate.txt"
queue_metrics="$REPORT_DIR/build_queue_metrics.txt"
progress_rollup="$REPORT_DIR/build_progress_rollup.txt"
check_report="$REPORT_DIR/build_check_report.txt"
check_rollup="$REPORT_DIR/build_check_status_rollup.txt"
check_gate="$REPORT_DIR/build_check_gate.txt"
check_stats="$REPORT_DIR/build_check_stats.txt"
toolchain_session="$REPORT_DIR/build_toolchain_session_report.txt"
preflight_gate="$REPORT_DIR/build_preflight_gate.txt"
preflight_gate_trend="$REPORT_DIR/build_preflight_gate_trend.txt"
summary_alerts_json="$REPORT_DIR/build_summary_alerts.json"
summary_alerts_trend_json="$REPORT_DIR/build_summary_alerts_trend.json"
summary_alerts_stats_txt="$REPORT_DIR/build_summary_alerts_stats.txt"
summary_alerts_stats_trend_txt="$REPORT_DIR/build_summary_alerts_stats_trend.txt"
summary_alerts_stats_delta_txt="$REPORT_DIR/build_summary_alerts_stats_delta.txt"
summary_alerts_stats_report_txt="$REPORT_DIR/build_summary_alerts_stats_report.txt"
summary_alerts_stats_report_json="$REPORT_DIR/build_summary_alerts_stats_report.json"
summary_alerts_stats_report_md_validate="$REPORT_DIR/build_summary_alerts_stats_report_md_validate.txt"
summary_alerts_stats_report_html_validate="$REPORT_DIR/build_summary_alerts_stats_html_validate.txt"
summary_alerts_stats_export_validate="$REPORT_DIR/build_summary_alerts_stats_export_validate.txt"
summary_alerts_stats_history_report_txt="$REPORT_DIR/build_summary_alerts_stats_history_report.txt"
summary_alerts_stats_history_report_json="$REPORT_DIR/build_summary_alerts_stats_history_report.json"
summary_alerts_stats_history_report_validate="$REPORT_DIR/build_summary_alerts_stats_history_report_validate.txt"
summary_alerts_stats_history_report_md_validate="$REPORT_DIR/build_summary_alerts_stats_history_report_md_validate.txt"
summary_alerts_stats_history_report_html_validate="$REPORT_DIR/build_summary_alerts_stats_history_report_html_validate.txt"
summary_alerts_stats_history_table_txt="$REPORT_DIR/build_summary_alerts_stats_history_table.txt"
summary_alerts_stats_history_table_validate="$REPORT_DIR/build_summary_alerts_stats_history_table_validate.txt"
summary_alerts_stats_history_table_md_validate="$REPORT_DIR/build_summary_alerts_stats_history_table_md_validate.txt"
summary_alerts_stats_history_table_html_validate="$REPORT_DIR/build_summary_alerts_stats_history_table_html_validate.txt"
summary_alerts_stats_history_score_txt="$REPORT_DIR/build_summary_alerts_stats_history_score.txt"
summary_alerts_stats_history_score_validate="$REPORT_DIR/build_summary_alerts_stats_history_score_validate.txt"
summary_alerts_stats_history_anomalies_txt="$REPORT_DIR/build_summary_alerts_stats_history_anomalies.txt"
summary_alerts_stats_history_anomalies_json="$REPORT_DIR/build_summary_alerts_stats_history_anomalies.json"
summary_alerts_stats_history_anomalies_validate="$REPORT_DIR/build_summary_alerts_stats_history_anomalies_validate.txt"
summary_alerts_stats_history_anomalies_md_validate="$REPORT_DIR/build_summary_alerts_stats_history_anomalies_md_validate.txt"
summary_alerts_stats_history_anomalies_html_validate="$REPORT_DIR/build_summary_alerts_stats_history_anomalies_html_validate.txt"
summary_alerts_stats_history_rollup_txt="$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
summary_alerts_stats_history_rollup_json="$REPORT_DIR/build_summary_alerts_stats_history_rollup.json"
summary_alerts_stats_history_rollup_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_validate.txt"
summary_alerts_stats_history_rollup_md_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_md_validate.txt"
summary_alerts_stats_history_rollup_html_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_html_validate.txt"
summary_alerts_stats_history_rollup_score_txt="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
summary_alerts_stats_history_rollup_score_json="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.json"
summary_alerts_stats_history_rollup_score_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score_validate.txt"
summary_alerts_stats_history_rollup_score_md_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score_md_validate.txt"
summary_alerts_stats_history_rollup_score_html_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score_html_validate.txt"
summary_alerts_stats_history_rollup_bundle_txt="$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle.txt"
summary_alerts_stats_history_rollup_bundle_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle_validate.txt"
summary_alerts_stats_history_rollup_overview_txt="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.txt"
summary_alerts_stats_history_rollup_overview_json="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.json"
summary_alerts_stats_history_rollup_overview_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_validate.txt"
summary_alerts_stats_history_rollup_overview_md_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_md_validate.txt"
summary_alerts_stats_history_rollup_overview_html_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_html_validate.txt"
summary_alerts_stats_history_rollup_history_txt="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.txt"
summary_alerts_stats_history_rollup_history_csv="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.csv"
summary_alerts_stats_history_rollup_history_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_validate.txt"
summary_alerts_stats_history_rollup_history_md_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_md_validate.txt"
summary_alerts_stats_history_rollup_history_html_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_html_validate.txt"
summary_alerts_stats_history_rollup_history_csv_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_csv_validate.txt"
summary_alerts_stats_history_rollup_trend_txt="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.txt"
summary_alerts_stats_history_rollup_trend_json="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.json"
summary_alerts_stats_history_rollup_trend_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend_validate.txt"
summary_alerts_stats_history_rollup_trend_md_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend_md_validate.txt"
summary_alerts_stats_history_rollup_trend_html_validate="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend_html_validate.txt"
summary_bundle_txt="$REPORT_DIR/build_summary_bundle.txt"
summary_bundle_index_trend="$REPORT_DIR/build_summary_bundle_index_trend.txt"
summary_bundle_index_delta="$REPORT_DIR/build_summary_bundle_index_delta.txt"
summary_bundle_index_overview="$REPORT_DIR/build_summary_bundle_index_overview.txt"
summary_bundle_index_score="$REPORT_DIR/build_summary_bundle_index_score.txt"
preflight_gate_validate="$REPORT_DIR/build_preflight_gate_validate.txt"
preflight_trend="$REPORT_DIR/preflight_trend.txt"

overall=$(report_result "$build_health")
gate=$(report_result "$build_gate")
check_gate_result=$(report_result "$check_gate")
gate_validate=$(report_result "$build_gate_validate")
gate_warn=$(value_from_report "$build_gate_trend" "warn")
gate_fail=$(value_from_report "$build_gate_trend" "fail")

queue_ok=$(value_from_report "$queue_metrics" "ok")
queue_fail=$(value_from_report "$queue_metrics" "fail")
queue_timeout=$(value_from_report "$queue_metrics" "timeout")

sys_total=$(value_from_section "$progress_rollup" "build_system" "manifest_total")
sys_done=$(value_from_section "$progress_rollup" "build_system" "state_done")
mini_total=$(value_from_section "$progress_rollup" "mini_system" "manifest_total")
mini_done=$(value_from_section "$progress_rollup" "mini_system" "state_done")
check_failures=$(value_from_report "$check_report" "check_failures")
check_fail_ignored=$(value_from_report "$check_report" "check_fail_ignored")
check_missing=$(value_from_report "$check_report" "check_missing")
check_fail_rate=$(value_from_report "$check_stats" "fail_rate")
check_ignored_rate=$(value_from_report "$check_stats" "ignored_rate")
toolchain_session_result=$(value_from_report "$toolchain_session" "result")
toolchain_session_preflight=$(value_from_report "$toolchain_session" "preflight_result")
toolchain_session_toolchain=$(value_from_report "$toolchain_session" "toolchain_result")
preflight_gate_result=$(value_from_report "$preflight_gate" "result")
preflight_gate_warn=$(value_from_report "$preflight_gate_trend" "warn")
preflight_gate_fail=$(value_from_report "$preflight_gate_trend" "fail")
preflight_gate_validate_result=$(report_result "$preflight_gate_validate")
preflight_avg_warns=$(value_from_report "$preflight_trend" "avg_warns")
summary_alerts_result=$(value_from_json_string "$summary_alerts_json" "result")
summary_alerts_count=$(value_from_json_number "$summary_alerts_json" "alerts")
summary_alerts_avg=$(value_from_json_number "$summary_alerts_trend_json" "avg_alerts")
summary_alerts_stats_total=$(value_from_report "$summary_alerts_stats_txt" "alerts_total")
summary_alerts_stats_gate=$(value_from_report "$summary_alerts_stats_txt" "gate")
summary_alerts_stats_checks=$(value_from_report "$summary_alerts_stats_txt" "checks")
summary_alerts_stats_preflight=$(value_from_report "$summary_alerts_stats_txt" "preflight")
summary_alerts_stats_bundle=$(value_from_report "$summary_alerts_stats_txt" "bundle")
summary_alerts_stats_items=$(value_from_report "$summary_alerts_stats_txt" "alerts_items")
summary_alerts_stats_other=$(value_from_report "$summary_alerts_stats_txt" "other")
summary_alerts_stats_result=$(value_from_report "$summary_alerts_stats_txt" "result")
summary_alerts_stats_bundle_score=$(value_from_report "$summary_alerts_stats_txt" "bundle_score")
summary_alerts_stats_bundle_score_result=$(value_from_report "$summary_alerts_stats_txt" "bundle_score_result")
summary_alerts_stats_trend_avg_alerts=$(value_from_report "$summary_alerts_stats_trend_txt" "avg_alerts")
summary_alerts_stats_trend_avg_score=$(value_from_report "$summary_alerts_stats_trend_txt" "avg_bundle_score")
summary_alerts_stats_trend_warn=$(value_from_report "$summary_alerts_stats_trend_txt" "warn")
summary_alerts_stats_trend_result=$(value_from_report "$summary_alerts_stats_trend_txt" "result")
summary_alerts_stats_delta_alerts=$(value_from_report "$summary_alerts_stats_delta_txt" "alerts_delta")
summary_alerts_stats_delta_score=$(value_from_report "$summary_alerts_stats_delta_txt" "score_delta")
summary_alerts_stats_delta_result=$(value_from_report "$summary_alerts_stats_delta_txt" "result")
summary_alerts_stats_report_result=$(value_from_report "$summary_alerts_stats_report_txt" "result")
summary_alerts_stats_report_json_result=$(value_from_json_string "$summary_alerts_stats_report_json" "result")
summary_alerts_stats_report_md_validate_result=$(report_result "$summary_alerts_stats_report_md_validate")
summary_alerts_stats_report_html_validate_result=$(report_result "$summary_alerts_stats_report_html_validate")
summary_alerts_stats_export_validate_result=$(report_result "$summary_alerts_stats_export_validate")
summary_alerts_stats_history_entries=$(value_from_report "$summary_alerts_stats_history_report_txt" "entries")
summary_alerts_stats_history_last_alerts=$(value_from_report "$summary_alerts_stats_history_report_txt" "last_alerts_total")
summary_alerts_stats_history_last_score=$(value_from_report "$summary_alerts_stats_history_report_txt" "last_bundle_score")
summary_alerts_stats_history_result=$(value_from_report "$summary_alerts_stats_history_report_txt" "result")
summary_alerts_stats_history_json_result=$(value_from_json_string "$summary_alerts_stats_history_report_json" "result")
summary_alerts_stats_history_validate_result=$(report_result "$summary_alerts_stats_history_report_validate")
summary_alerts_stats_history_md_validate_result=$(report_result "$summary_alerts_stats_history_report_md_validate")
summary_alerts_stats_history_html_validate_result=$(report_result "$summary_alerts_stats_history_report_html_validate")
summary_alerts_stats_history_table_entries=$(value_from_report "$summary_alerts_stats_history_table_txt" "entries")
summary_alerts_stats_history_table_result=$(value_from_report "$summary_alerts_stats_history_table_txt" "result")
summary_alerts_stats_history_table_validate_result=$(report_result "$summary_alerts_stats_history_table_validate")
summary_alerts_stats_history_table_md_validate_result=$(report_result "$summary_alerts_stats_history_table_md_validate")
summary_alerts_stats_history_table_html_validate_result=$(report_result "$summary_alerts_stats_history_table_html_validate")
summary_alerts_stats_history_score_value=$(value_from_report "$summary_alerts_stats_history_score_txt" "score")
summary_alerts_stats_history_score_result=$(value_from_report "$summary_alerts_stats_history_score_txt" "result")
summary_alerts_stats_history_score_validate_result=$(report_result "$summary_alerts_stats_history_score_validate")
summary_alerts_stats_history_anomalies_entries=$(value_from_report "$summary_alerts_stats_history_anomalies_txt" "entries")
summary_alerts_stats_history_anomalies_count=$(value_from_report "$summary_alerts_stats_history_anomalies_txt" "anomalies")
summary_alerts_stats_history_anomalies_max_alerts=$(value_from_report "$summary_alerts_stats_history_anomalies_txt" "max_alerts_delta")
summary_alerts_stats_history_anomalies_min_score=$(value_from_report "$summary_alerts_stats_history_anomalies_txt" "min_score_delta")
summary_alerts_stats_history_anomalies_result=$(value_from_report "$summary_alerts_stats_history_anomalies_txt" "result")
summary_alerts_stats_history_anomalies_json_result=$(value_from_json_string "$summary_alerts_stats_history_anomalies_json" "result")
summary_alerts_stats_history_anomalies_validate_result=$(report_result "$summary_alerts_stats_history_anomalies_validate")
summary_alerts_stats_history_anomalies_md_validate_result=$(report_result "$summary_alerts_stats_history_anomalies_md_validate")
summary_alerts_stats_history_anomalies_html_validate_result=$(report_result "$summary_alerts_stats_history_anomalies_html_validate")
summary_alerts_stats_history_rollup_entries=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "entries")
summary_alerts_stats_history_rollup_window=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "window")
summary_alerts_stats_history_rollup_prev=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "prev_present")
summary_alerts_stats_history_rollup_last_alerts=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "last_avg_alerts")
summary_alerts_stats_history_rollup_last_score=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "last_avg_score")
summary_alerts_stats_history_rollup_prev_alerts=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "prev_avg_alerts")
summary_alerts_stats_history_rollup_prev_score=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "prev_avg_score")
summary_alerts_stats_history_rollup_delta_alerts=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "delta_alerts")
summary_alerts_stats_history_rollup_delta_score=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "delta_score")
summary_alerts_stats_history_rollup_result=$(value_from_report "$summary_alerts_stats_history_rollup_txt" "result")
summary_alerts_stats_history_rollup_json_result=$(value_from_json_string "$summary_alerts_stats_history_rollup_json" "result")
summary_alerts_stats_history_rollup_validate_result=$(report_result "$summary_alerts_stats_history_rollup_validate")
summary_alerts_stats_history_rollup_md_validate_result=$(report_result "$summary_alerts_stats_history_rollup_md_validate")
summary_alerts_stats_history_rollup_html_validate_result=$(report_result "$summary_alerts_stats_history_rollup_html_validate")
summary_alerts_stats_history_rollup_score_value=$(value_from_report "$summary_alerts_stats_history_rollup_score_txt" "score")
summary_alerts_stats_history_rollup_score_result=$(value_from_report "$summary_alerts_stats_history_rollup_score_txt" "result")
summary_alerts_stats_history_rollup_score_json_result=$(value_from_json_string "$summary_alerts_stats_history_rollup_score_json" "result")
summary_alerts_stats_history_rollup_score_validate_result=$(report_result "$summary_alerts_stats_history_rollup_score_validate")
summary_alerts_stats_history_rollup_score_md_validate_result=$(report_result "$summary_alerts_stats_history_rollup_score_md_validate")
summary_alerts_stats_history_rollup_score_html_validate_result=$(report_result "$summary_alerts_stats_history_rollup_score_html_validate")
summary_alerts_stats_history_rollup_bundle_files=$(value_from_report "$summary_alerts_stats_history_rollup_bundle_txt" "files")
summary_alerts_stats_history_rollup_bundle_missing=$(value_from_report "$summary_alerts_stats_history_rollup_bundle_txt" "missing_count")
summary_alerts_stats_history_rollup_bundle_result=$(value_from_report "$summary_alerts_stats_history_rollup_bundle_txt" "result")
summary_alerts_stats_history_rollup_bundle_validate_result=$(report_result "$summary_alerts_stats_history_rollup_bundle_validate")
summary_alerts_stats_history_rollup_overview_result=$(value_from_report "$summary_alerts_stats_history_rollup_overview_txt" "result")
summary_alerts_stats_history_rollup_overview_rollup_result=$(value_from_report "$summary_alerts_stats_history_rollup_overview_txt" "rollup_result")
summary_alerts_stats_history_rollup_overview_score_result=$(value_from_report "$summary_alerts_stats_history_rollup_overview_txt" "rollup_score_result")
summary_alerts_stats_history_rollup_overview_bundle_validate=$(value_from_report "$summary_alerts_stats_history_rollup_overview_txt" "rollup_bundle_validate")
summary_alerts_stats_history_rollup_overview_json_result=$(value_from_json_string "$summary_alerts_stats_history_rollup_overview_json" "result")
summary_alerts_stats_history_rollup_overview_validate_result=$(report_result "$summary_alerts_stats_history_rollup_overview_validate")
summary_alerts_stats_history_rollup_overview_md_validate_result=$(report_result "$summary_alerts_stats_history_rollup_overview_md_validate")
summary_alerts_stats_history_rollup_overview_html_validate_result=$(report_result "$summary_alerts_stats_history_rollup_overview_html_validate")
summary_alerts_stats_history_rollup_history_entries=$(csv_entries "$summary_alerts_stats_history_rollup_history_csv")
summary_alerts_stats_history_rollup_history_date=$(value_from_report "$summary_alerts_stats_history_rollup_history_txt" "date")
summary_alerts_stats_history_rollup_history_delta_alerts=$(value_from_report "$summary_alerts_stats_history_rollup_history_txt" "delta_alerts")
summary_alerts_stats_history_rollup_history_delta_score=$(value_from_report "$summary_alerts_stats_history_rollup_history_txt" "delta_score")
summary_alerts_stats_history_rollup_history_score=$(value_from_report "$summary_alerts_stats_history_rollup_history_txt" "score")
summary_alerts_stats_history_rollup_history_result=$(value_from_report "$summary_alerts_stats_history_rollup_history_txt" "result")
summary_alerts_stats_history_rollup_history_validate_result=$(report_result "$summary_alerts_stats_history_rollup_history_validate")
summary_alerts_stats_history_rollup_history_md_validate_result=$(report_result "$summary_alerts_stats_history_rollup_history_md_validate")
summary_alerts_stats_history_rollup_history_html_validate_result=$(report_result "$summary_alerts_stats_history_rollup_history_html_validate")
summary_alerts_stats_history_rollup_history_csv_validate_result=$(report_result "$summary_alerts_stats_history_rollup_history_csv_validate")
summary_alerts_stats_history_rollup_trend_entries=$(value_from_report "$summary_alerts_stats_history_rollup_trend_txt" "entries")
summary_alerts_stats_history_rollup_trend_avg_delta_alerts=$(value_from_report "$summary_alerts_stats_history_rollup_trend_txt" "avg_delta_alerts")
summary_alerts_stats_history_rollup_trend_avg_delta_score=$(value_from_report "$summary_alerts_stats_history_rollup_trend_txt" "avg_delta_score")
summary_alerts_stats_history_rollup_trend_avg_score=$(value_from_report "$summary_alerts_stats_history_rollup_trend_txt" "avg_score")
summary_alerts_stats_history_rollup_trend_warn_rollup=$(value_from_report "$summary_alerts_stats_history_rollup_trend_txt" "warn_rollup")
summary_alerts_stats_history_rollup_trend_warn_score=$(value_from_report "$summary_alerts_stats_history_rollup_trend_txt" "warn_score")
summary_alerts_stats_history_rollup_trend_result=$(value_from_report "$summary_alerts_stats_history_rollup_trend_txt" "result")
summary_alerts_stats_history_rollup_trend_json_result=$(value_from_json_string "$summary_alerts_stats_history_rollup_trend_json" "result")
summary_alerts_stats_history_rollup_trend_validate_result=$(report_result "$summary_alerts_stats_history_rollup_trend_validate")
summary_alerts_stats_history_rollup_trend_md_validate_result=$(report_result "$summary_alerts_stats_history_rollup_trend_md_validate")
summary_alerts_stats_history_rollup_trend_html_validate_result=$(report_result "$summary_alerts_stats_history_rollup_trend_html_validate")
summary_bundle_result=$(value_from_report "$summary_bundle_txt" "result")
summary_bundle_missing=$(value_from_report "$summary_bundle_txt" "missing_count")
summary_bundle_index_entries=$(value_from_report "$summary_bundle_index_trend" "entries")
summary_bundle_index_avg=$(value_from_report "$summary_bundle_index_trend" "avg_files")
summary_bundle_index_warn=$(value_from_report "$summary_bundle_index_trend" "warn")
summary_bundle_index_result=$(value_from_report "$summary_bundle_index_trend" "result")
summary_bundle_index_delta_files=$(value_from_report "$summary_bundle_index_delta" "delta_files")
summary_bundle_index_delta_result=$(value_from_report "$summary_bundle_index_delta" "result")
summary_bundle_index_last_generated=$(value_from_report "$summary_bundle_index_delta" "last_generated")
summary_bundle_index_prev_generated=$(value_from_report "$summary_bundle_index_delta" "prev_generated")
summary_bundle_index_last_files=$(value_from_report "$summary_bundle_index_delta" "last_files")
summary_bundle_index_prev_files=$(value_from_report "$summary_bundle_index_delta" "prev_files")
summary_bundle_index_overview_result=$(value_from_report "$summary_bundle_index_overview" "result")
summary_bundle_index_overview_trend=$(value_from_report "$summary_bundle_index_overview" "trend_result")
summary_bundle_index_overview_delta=$(value_from_report "$summary_bundle_index_overview" "delta_result")
summary_bundle_index_score_value=$(value_from_report "$summary_bundle_index_score" "score")
summary_bundle_index_score_result=$(value_from_report "$summary_bundle_index_score" "result")
summary_bundle_index_score_warn=$(value_from_report "$summary_bundle_index_score" "warn")
summary_bundle_index_score_delta=$(value_from_report "$summary_bundle_index_score" "delta_files")
summary_alerts_items_trend="$REPORT_DIR/build_summary_alerts_items_trend.json"
summary_alerts_items_avg_total=$(value_from_json_number "$summary_alerts_items_trend" "avg_total_items")
summary_alerts_items_avg_unique=$(value_from_json_number "$summary_alerts_items_trend" "avg_unique_items")
summary_alerts_items_trend_warn=$(value_from_json_number "$summary_alerts_items_trend" "warn")
summary_alerts_items_trend_result=$(value_from_json_string "$summary_alerts_items_trend" "result")
summary_alerts_items_delta="$REPORT_DIR/build_summary_alerts_items_delta.json"
summary_alerts_items_delta_total=$(value_from_json_number "$summary_alerts_items_delta" "delta_total_items")
summary_alerts_items_delta_unique=$(value_from_json_number "$summary_alerts_items_delta" "delta_unique_items")
summary_alerts_items_delta_result=$(value_from_json_string "$summary_alerts_items_delta" "result")
summary_alerts_items_delta_top_changed=$(value_from_json_string "$summary_alerts_items_delta" "top_text_changed")
summary_alerts_items_delta_mode_changed=$(value_from_json_string "$summary_alerts_items_delta" "items_mode_changed")
alerts_items_report="$REPORT_DIR/build_summary_alerts_items_report.txt"
alerts_items_report_mode=$(value_from_report "$alerts_items_report" "items_mode")
alerts_items_report_top=$(value_from_report "$alerts_items_report" "items_top")
alerts_items_report_result=$(value_from_report "$alerts_items_report" "result")
alerts_items_overview="$REPORT_DIR/build_summary_alerts_items_overview.json"
alerts_items_overview_result=$(value_from_json_string "$alerts_items_overview" "result")
alerts_items_overview_items_mode=$(value_from_json_string "$alerts_items_overview" "items_mode")
alerts_items_overview_items_top=$(value_from_json_string "$alerts_items_overview" "items_top")

check_groups="{}"
if [ -f "$check_rollup" ]; then
	check_groups=$(awk '
		/^\[group:/ {
			g=$0; sub(/^\[group:/,"",g); sub(/\]$/,"",g); groups[g]=1
		}
		$1=="ok:" {ok[g]=$2}
		$1=="fail:" {fail[g]=$2}
		$1=="fail_ignored:" {ign[g]=$2}
		$1=="other:" {other[g]=$2}
		END {
			first=1
			printf "{"
			for (g in groups) {
				if (!first) printf ","
				first=0
				printf "\"%s\": {\"ok\": %d, \"fail\": %d, \"fail_ignored\": %d, \"other\": %d}", g, ok[g]+0, fail[g]+0, ign[g]+0, other[g]+0
			}
			printf "}"
		}
	' "$check_rollup")
fi

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"overall\": \"${overall:-unknown}\","
	echo "  \"gate\": \"${gate:-unknown}\","
	echo "  \"gate_validate\": \"${gate_validate:-unknown}\","
	echo "  \"gate_trend\": {"
	echo "    \"warn\": ${gate_warn:-0},"
	echo "    \"fail\": ${gate_fail:-0}"
	echo "  },"
	echo "  \"queue\": {"
	echo "    \"ok\": ${queue_ok:-0},"
	echo "    \"fail\": ${queue_fail:-0},"
	echo "    \"timeout\": ${queue_timeout:-0}"
	echo "  },"
	echo "  \"build_system\": {"
	echo "    \"total\": ${sys_total:-0},"
	echo "    \"done\": ${sys_done:-0}"
	echo "  },"
	echo "  \"mini_system\": {"
	echo "    \"total\": ${mini_total:-0},"
	echo "    \"done\": ${mini_done:-0}"
	echo "  },"
	echo "  \"check\": {"
	echo "    \"failures\": ${check_failures:-0},"
	echo "    \"ignored\": ${check_fail_ignored:-0},"
	echo "    \"missing\": ${check_missing:-0}"
	echo "  },"
	echo "  \"check_rates\": {"
	echo "    \"fail_rate\": ${check_fail_rate:-0},"
	echo "    \"ignored_rate\": ${check_ignored_rate:-0}"
	echo "  },"
	echo "  \"toolchain_session\": {"
	echo "    \"result\": \"${toolchain_session_result:-unknown}\","
	echo "    \"preflight\": \"${toolchain_session_preflight:-unknown}\","
	echo "    \"toolchain\": \"${toolchain_session_toolchain:-unknown}\""
	echo "  },"
	echo "  \"preflight_gate\": \"${preflight_gate_result:-unknown}\","
	echo "  \"preflight_gate_validate\": \"${preflight_gate_validate_result:-unknown}\","
	echo "  \"preflight_gate_trend\": {"
	echo "    \"warn\": ${preflight_gate_warn:-0},"
	echo "    \"fail\": ${preflight_gate_fail:-0}"
	echo "  },"
	echo "  \"preflight_trend\": {"
	echo "    \"avg_warns\": ${preflight_avg_warns:-0}"
	echo "  },"
	echo "  \"summary_alerts\": {"
	echo "    \"result\": \"${summary_alerts_result:-unknown}\","
	echo "    \"alerts\": ${summary_alerts_count:-0}"
	echo "  },"
	echo "  \"summary_alerts_trend\": {"
	echo "    \"avg_alerts\": ${summary_alerts_avg:-0}"
	echo "  },"
	echo "  \"summary_alerts_stats\": {"
	echo "    \"total\": ${summary_alerts_stats_total:-0},"
	echo "    \"gate\": ${summary_alerts_stats_gate:-0},"
	echo "    \"checks\": ${summary_alerts_stats_checks:-0},"
	echo "    \"preflight\": ${summary_alerts_stats_preflight:-0},"
	echo "    \"bundle\": ${summary_alerts_stats_bundle:-0},"
	echo "    \"alerts_items\": ${summary_alerts_stats_items:-0},"
	echo "    \"other\": ${summary_alerts_stats_other:-0},"
	echo "    \"bundle_score\": ${summary_alerts_stats_bundle_score:-0},"
	echo "    \"bundle_score_result\": \"${summary_alerts_stats_bundle_score_result:-unknown}\","
	echo "    \"result\": \"${summary_alerts_stats_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_report\": {"
	echo "    \"entries\": ${summary_alerts_stats_history_entries:-0},"
	echo "    \"last_alerts_total\": ${summary_alerts_stats_history_last_alerts:-0},"
	echo "    \"last_bundle_score\": ${summary_alerts_stats_history_last_score:-0},"
	echo "    \"result\": \"${summary_alerts_stats_history_result:-unknown}\","
	echo "    \"json_result\": \"${summary_alerts_stats_history_json_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_validate_result:-unknown}\","
	echo "    \"md_validate\": \"${summary_alerts_stats_history_md_validate_result:-unknown}\","
	echo "    \"html_validate\": \"${summary_alerts_stats_history_html_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_table\": {"
	echo "    \"entries\": ${summary_alerts_stats_history_table_entries:-0},"
	echo "    \"result\": \"${summary_alerts_stats_history_table_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_table_validate_result:-unknown}\","
	echo "    \"md_validate\": \"${summary_alerts_stats_history_table_md_validate_result:-unknown}\","
	echo "    \"html_validate\": \"${summary_alerts_stats_history_table_html_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_score\": {"
	echo "    \"score\": ${summary_alerts_stats_history_score_value:-0},"
	echo "    \"result\": \"${summary_alerts_stats_history_score_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_score_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_anomalies\": {"
	echo "    \"entries\": ${summary_alerts_stats_history_anomalies_entries:-0},"
	echo "    \"anomalies\": ${summary_alerts_stats_history_anomalies_count:-0},"
	echo "    \"max_alerts_delta\": ${summary_alerts_stats_history_anomalies_max_alerts:-0},"
	echo "    \"min_score_delta\": ${summary_alerts_stats_history_anomalies_min_score:-0},"
	echo "    \"result\": \"${summary_alerts_stats_history_anomalies_result:-unknown}\","
	echo "    \"json_result\": \"${summary_alerts_stats_history_anomalies_json_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_anomalies_validate_result:-unknown}\","
	echo "    \"md_validate\": \"${summary_alerts_stats_history_anomalies_md_validate_result:-unknown}\","
	echo "    \"html_validate\": \"${summary_alerts_stats_history_anomalies_html_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_rollup\": {"
	echo "    \"entries\": ${summary_alerts_stats_history_rollup_entries:-0},"
	echo "    \"window\": ${summary_alerts_stats_history_rollup_window:-0},"
	echo "    \"prev_present\": \"${summary_alerts_stats_history_rollup_prev:-false}\","
	echo "    \"last_avg_alerts\": ${summary_alerts_stats_history_rollup_last_alerts:-0},"
	echo "    \"last_avg_score\": ${summary_alerts_stats_history_rollup_last_score:-0},"
	echo "    \"prev_avg_alerts\": ${summary_alerts_stats_history_rollup_prev_alerts:-0},"
	echo "    \"prev_avg_score\": ${summary_alerts_stats_history_rollup_prev_score:-0},"
	echo "    \"delta_alerts\": ${summary_alerts_stats_history_rollup_delta_alerts:-0},"
	echo "    \"delta_score\": ${summary_alerts_stats_history_rollup_delta_score:-0},"
	echo "    \"result\": \"${summary_alerts_stats_history_rollup_result:-unknown}\","
	echo "    \"json_result\": \"${summary_alerts_stats_history_rollup_json_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_rollup_validate_result:-unknown}\","
	echo "    \"md_validate\": \"${summary_alerts_stats_history_rollup_md_validate_result:-unknown}\","
	echo "    \"html_validate\": \"${summary_alerts_stats_history_rollup_html_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_rollup_score\": {"
	echo "    \"score\": ${summary_alerts_stats_history_rollup_score_value:-0},"
	echo "    \"result\": \"${summary_alerts_stats_history_rollup_score_result:-unknown}\","
	echo "    \"json_result\": \"${summary_alerts_stats_history_rollup_score_json_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_rollup_score_validate_result:-unknown}\","
	echo "    \"md_validate\": \"${summary_alerts_stats_history_rollup_score_md_validate_result:-unknown}\","
	echo "    \"html_validate\": \"${summary_alerts_stats_history_rollup_score_html_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_rollup_bundle\": {"
	echo "    \"files\": ${summary_alerts_stats_history_rollup_bundle_files:-0},"
	echo "    \"missing_count\": ${summary_alerts_stats_history_rollup_bundle_missing:-0},"
	echo "    \"result\": \"${summary_alerts_stats_history_rollup_bundle_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_rollup_bundle_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_rollup_overview\": {"
	echo "    \"result\": \"${summary_alerts_stats_history_rollup_overview_result:-unknown}\","
	echo "    \"rollup_result\": \"${summary_alerts_stats_history_rollup_overview_rollup_result:-unknown}\","
	echo "    \"score_result\": \"${summary_alerts_stats_history_rollup_overview_score_result:-unknown}\","
	echo "    \"bundle_validate\": \"${summary_alerts_stats_history_rollup_overview_bundle_validate:-unknown}\","
	echo "    \"json_result\": \"${summary_alerts_stats_history_rollup_overview_json_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_rollup_overview_validate_result:-unknown}\","
	echo "    \"md_validate\": \"${summary_alerts_stats_history_rollup_overview_md_validate_result:-unknown}\","
	echo "    \"html_validate\": \"${summary_alerts_stats_history_rollup_overview_html_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_rollup_history\": {"
	echo "    \"entries\": ${summary_alerts_stats_history_rollup_history_entries:-0},"
	echo "    \"last_date\": \"${summary_alerts_stats_history_rollup_history_date:-unknown}\","
	echo "    \"last_delta_alerts\": ${summary_alerts_stats_history_rollup_history_delta_alerts:-0},"
	echo "    \"last_delta_score\": ${summary_alerts_stats_history_rollup_history_delta_score:-0},"
	echo "    \"last_score\": ${summary_alerts_stats_history_rollup_history_score:-0},"
	echo "    \"result\": \"${summary_alerts_stats_history_rollup_history_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_rollup_history_validate_result:-unknown}\","
	echo "    \"md_validate\": \"${summary_alerts_stats_history_rollup_history_md_validate_result:-unknown}\","
	echo "    \"html_validate\": \"${summary_alerts_stats_history_rollup_history_html_validate_result:-unknown}\","
	echo "    \"csv_validate\": \"${summary_alerts_stats_history_rollup_history_csv_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_history_rollup_trend\": {"
	echo "    \"entries\": ${summary_alerts_stats_history_rollup_trend_entries:-0},"
	echo "    \"avg_delta_alerts\": ${summary_alerts_stats_history_rollup_trend_avg_delta_alerts:-0},"
	echo "    \"avg_delta_score\": ${summary_alerts_stats_history_rollup_trend_avg_delta_score:-0},"
	echo "    \"avg_score\": ${summary_alerts_stats_history_rollup_trend_avg_score:-0},"
	echo "    \"warn_rollup\": ${summary_alerts_stats_history_rollup_trend_warn_rollup:-0},"
	echo "    \"warn_score\": ${summary_alerts_stats_history_rollup_trend_warn_score:-0},"
	echo "    \"result\": \"${summary_alerts_stats_history_rollup_trend_result:-unknown}\","
	echo "    \"json_result\": \"${summary_alerts_stats_history_rollup_trend_json_result:-unknown}\","
	echo "    \"validate\": \"${summary_alerts_stats_history_rollup_trend_validate_result:-unknown}\","
	echo "    \"md_validate\": \"${summary_alerts_stats_history_rollup_trend_md_validate_result:-unknown}\","
	echo "    \"html_validate\": \"${summary_alerts_stats_history_rollup_trend_html_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_trend\": {"
	echo "    \"avg_alerts\": ${summary_alerts_stats_trend_avg_alerts:-0},"
	echo "    \"avg_bundle_score\": ${summary_alerts_stats_trend_avg_score:-0},"
	echo "    \"warn\": ${summary_alerts_stats_trend_warn:-0},"
	echo "    \"result\": \"${summary_alerts_stats_trend_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_delta\": {"
	echo "    \"alerts_delta\": ${summary_alerts_stats_delta_alerts:-0},"
	echo "    \"score_delta\": ${summary_alerts_stats_delta_score:-0},"
	echo "    \"result\": \"${summary_alerts_stats_delta_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_report\": {"
	echo "    \"result\": \"${summary_alerts_stats_report_result:-unknown}\","
	echo "    \"json_result\": \"${summary_alerts_stats_report_json_result:-unknown}\","
	echo "    \"md_validate\": \"${summary_alerts_stats_report_md_validate_result:-unknown}\","
	echo "    \"html_validate\": \"${summary_alerts_stats_report_html_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_stats_export\": {"
	echo "    \"validate\": \"${summary_alerts_stats_export_validate_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_items_trend\": {"
	echo "    \"avg_total_items\": ${summary_alerts_items_avg_total:-0},"
	echo "    \"avg_unique_items\": ${summary_alerts_items_avg_unique:-0},"
	echo "    \"warn\": ${summary_alerts_items_trend_warn:-0},"
	echo "    \"result\": \"${summary_alerts_items_trend_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_items_delta\": {"
	echo "    \"delta_total_items\": ${summary_alerts_items_delta_total:-0},"
	echo "    \"delta_unique_items\": ${summary_alerts_items_delta_unique:-0},"
	echo "    \"top_text_changed\": \"${summary_alerts_items_delta_top_changed:-false}\","
	echo "    \"items_mode_changed\": \"${summary_alerts_items_delta_mode_changed:-false}\","
	echo "    \"result\": \"${summary_alerts_items_delta_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_items_report\": {"
	echo "    \"items_mode\": \"${alerts_items_report_mode:-unknown}\","
	echo "    \"items_top\": \"${alerts_items_report_top:-none}\","
	echo "    \"result\": \"${alerts_items_report_result:-unknown}\""
	echo "  },"
	echo "  \"summary_alerts_items_overview\": {"
	echo "    \"items_mode\": \"${alerts_items_overview_items_mode:-unknown}\","
	echo "    \"items_top\": \"${alerts_items_overview_items_top:-none}\","
	echo "    \"result\": \"${alerts_items_overview_result:-unknown}\""
	echo "  },"
	echo "  \"summary_bundle\": {"
	echo "    \"result\": \"${summary_bundle_result:-unknown}\","
	echo "    \"missing\": ${summary_bundle_missing:-0},"
	echo "    \"index_trend\": {"
	echo "      \"entries\": ${summary_bundle_index_entries:-0},"
	echo "      \"avg_files\": ${summary_bundle_index_avg:-0},"
	echo "      \"warn\": ${summary_bundle_index_warn:-0},"
	echo "      \"result\": \"${summary_bundle_index_result:-unknown}\""
	echo "    },"
	echo "    \"index_delta\": {"
	echo "      \"delta_files\": ${summary_bundle_index_delta_files:-0},"
	echo "      \"result\": \"${summary_bundle_index_delta_result:-unknown}\","
	echo "      \"last_generated\": \"${summary_bundle_index_last_generated:-unknown}\","
	echo "      \"previous_generated\": \"${summary_bundle_index_prev_generated:-unknown}\","
	echo "      \"last_files\": ${summary_bundle_index_last_files:-0},"
	echo "      \"previous_files\": ${summary_bundle_index_prev_files:-0}"
	echo "    },"
	echo "    \"index_overview\": {"
	echo "      \"result\": \"${summary_bundle_index_overview_result:-unknown}\","
	echo "      \"trend_result\": \"${summary_bundle_index_overview_trend:-unknown}\","
	echo "      \"delta_result\": \"${summary_bundle_index_overview_delta:-unknown}\""
	echo "    },"
	echo "    \"index_score\": {"
	echo "      \"score\": ${summary_bundle_index_score_value:-0},"
	echo "      \"result\": \"${summary_bundle_index_score_result:-unknown}\","
	echo "      \"warn\": ${summary_bundle_index_score_warn:-0},"
	echo "      \"delta_files\": ${summary_bundle_index_score_delta:-0}"
	echo "    }"
	echo "  },"
	echo "  \"check_groups\": $check_groups,"
	echo "  \"check_gate\": \"${check_gate_result:-unknown}\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary JSON generated: $OUT_JSON"
