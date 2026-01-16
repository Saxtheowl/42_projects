#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
JSON_FILE="$REPORT_DIR/build_summary.json"
OUT_TXT="$REPORT_DIR/build_summary_report.txt"

usage() {
	cat <<EOF
Usage: $0 [--json <file>] [--out <file>]

Genere un rapport lisible a partir de build_summary.json.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--json) JSON_FILE="$2"; shift 2 ;;
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
	echo "build_summary_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "json: $JSON_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$JSON_FILE" ]; then
	echo "result: missing_json" >>"$OUT_TXT"
	echo "json missing" >>"$OUT_TXT"
	exit 0
fi

get_string_field() {
	local key="$1"
	grep -E "\"$key\"" "$JSON_FILE" | head -n 1 | awk -F'"' '{print $4}'
}

get_number_field() {
	local key="$1"
	grep -E "\"$key\"" "$JSON_FILE" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,'
}

get_nested_number() {
	local section="$1"
	local key="$2"
	grep -E "\"$section\"" -A4 "$JSON_FILE" | grep -E "\"$key\"" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,'
}

get_nested_string() {
	local section="$1"
	local key="$2"
	grep -E "\"$section\"" -A4 "$JSON_FILE" | grep -E "\"$key\"" | head -n 1 | awk -F'"' '{print $4}'
}

get_section_number() {
	local section="$1"
	local key="$2"
	awk -v sec="\"$section\"" -v key="\"$key\"" '
		$0 ~ sec {in=1; depth=0}
		in {
			if ($0 ~ /\{/) depth++
			if ($0 ~ key) {
				split($0, parts, ":")
				gsub(/[ ,]/, "", parts[2])
				print parts[2]
				exit
			}
			if ($0 ~ /\}/) {depth--; if (depth<=0) exit}
		}
	' "$JSON_FILE"
}

get_section_string() {
	local section="$1"
	local key="$2"
	awk -F'"' -v sec="\"$section\"" -v key="\"$key\"" '
		$0 ~ sec {in=1; depth=0}
		in {
			if ($0 ~ /\{/) depth++
			if ($0 ~ key) {print $4; exit}
			if ($0 ~ /\}/) {depth--; if (depth<=0) exit}
		}
	' "$JSON_FILE"
}

overall=$(get_string_field "overall")
gate=$(get_string_field "gate")
gate_validate=$(get_string_field "gate_validate")
toolchain_session=$(get_string_field "toolchain")
preflight_gate=$(get_string_field "preflight_gate")
preflight_gate_validate=$(get_string_field "preflight_gate_validate")

check_failures=$(get_number_field "failures")
check_ignored=$(get_number_field "ignored")
check_missing=$(get_number_field "missing")
sys_total=$(get_nested_number "build_system" "total")
sys_done=$(get_nested_number "build_system" "done")
mini_total=$(get_nested_number "mini_system" "total")
mini_done=$(get_nested_number "mini_system" "done")
queue_ok=$(get_nested_number "queue" "ok")
queue_fail=$(get_nested_number "queue" "fail")
queue_timeout=$(get_nested_number "queue" "timeout")
check_fail_rate=$(get_nested_number "check_rates" "fail_rate")
check_ignored_rate=$(get_nested_number "check_rates" "ignored_rate")

gate_warn=$(get_nested_number "gate_trend" "warn")
gate_fail=$(get_nested_number "gate_trend" "fail")

pre_gate_warn=$(get_nested_number "preflight_gate_trend" "warn")
pre_gate_fail=$(get_nested_number "preflight_gate_trend" "fail")
pre_avg_warns=$(get_nested_number "preflight_trend" "avg_warns")
summary_alerts_result=$(get_nested_string "summary_alerts" "result")
summary_alerts_count=$(get_nested_number "summary_alerts" "alerts")
summary_alerts_avg=$(get_nested_number "summary_alerts_trend" "avg_alerts")
summary_alerts_stats_total=$(get_nested_number "summary_alerts_stats" "total")
summary_alerts_stats_gate=$(get_nested_number "summary_alerts_stats" "gate")
summary_alerts_stats_checks=$(get_nested_number "summary_alerts_stats" "checks")
summary_alerts_stats_preflight=$(get_nested_number "summary_alerts_stats" "preflight")
summary_alerts_stats_bundle=$(get_nested_number "summary_alerts_stats" "bundle")
summary_alerts_stats_items=$(get_nested_number "summary_alerts_stats" "alerts_items")
summary_alerts_stats_other=$(get_nested_number "summary_alerts_stats" "other")
summary_alerts_stats_bundle_score=$(get_nested_number "summary_alerts_stats" "bundle_score")
summary_alerts_stats_bundle_score_result=$(get_nested_string "summary_alerts_stats" "bundle_score_result")
summary_alerts_stats_result=$(get_nested_string "summary_alerts_stats" "result")
summary_alerts_stats_history_entries=$(get_nested_number "summary_alerts_stats_history_report" "entries")
summary_alerts_stats_history_last_alerts=$(get_nested_number "summary_alerts_stats_history_report" "last_alerts_total")
summary_alerts_stats_history_last_score=$(get_nested_number "summary_alerts_stats_history_report" "last_bundle_score")
summary_alerts_stats_history_result=$(get_nested_string "summary_alerts_stats_history_report" "result")
summary_alerts_stats_history_json_result=$(get_nested_string "summary_alerts_stats_history_report" "json_result")
summary_alerts_stats_history_validate=$(get_nested_string "summary_alerts_stats_history_report" "validate")
summary_alerts_stats_history_md_validate=$(get_nested_string "summary_alerts_stats_history_report" "md_validate")
summary_alerts_stats_history_html_validate=$(get_nested_string "summary_alerts_stats_history_report" "html_validate")
summary_alerts_stats_history_table_entries=$(get_nested_number "summary_alerts_stats_history_table" "entries")
summary_alerts_stats_history_table_result=$(get_nested_string "summary_alerts_stats_history_table" "result")
summary_alerts_stats_history_table_validate=$(get_nested_string "summary_alerts_stats_history_table" "validate")
summary_alerts_stats_history_table_md_validate=$(get_nested_string "summary_alerts_stats_history_table" "md_validate")
summary_alerts_stats_history_table_html_validate=$(get_nested_string "summary_alerts_stats_history_table" "html_validate")
summary_alerts_stats_history_score_value=$(get_nested_number "summary_alerts_stats_history_score" "score")
summary_alerts_stats_history_score_result=$(get_nested_string "summary_alerts_stats_history_score" "result")
summary_alerts_stats_history_score_validate=$(get_nested_string "summary_alerts_stats_history_score" "validate")
summary_alerts_stats_history_anomalies_entries=$(get_nested_number "summary_alerts_stats_history_anomalies" "entries")
summary_alerts_stats_history_anomalies_count=$(get_nested_number "summary_alerts_stats_history_anomalies" "anomalies")
summary_alerts_stats_history_anomalies_max_alerts=$(get_nested_number "summary_alerts_stats_history_anomalies" "max_alerts_delta")
summary_alerts_stats_history_anomalies_min_score=$(get_nested_number "summary_alerts_stats_history_anomalies" "min_score_delta")
summary_alerts_stats_history_anomalies_result=$(get_nested_string "summary_alerts_stats_history_anomalies" "result")
summary_alerts_stats_history_anomalies_json_result=$(get_nested_string "summary_alerts_stats_history_anomalies" "json_result")
summary_alerts_stats_history_anomalies_validate=$(get_nested_string "summary_alerts_stats_history_anomalies" "validate")
summary_alerts_stats_history_anomalies_md_validate=$(get_nested_string "summary_alerts_stats_history_anomalies" "md_validate")
summary_alerts_stats_history_anomalies_html_validate=$(get_nested_string "summary_alerts_stats_history_anomalies" "html_validate")
summary_alerts_stats_history_rollup_entries=$(get_nested_number "summary_alerts_stats_history_rollup" "entries")
summary_alerts_stats_history_rollup_window=$(get_nested_number "summary_alerts_stats_history_rollup" "window")
summary_alerts_stats_history_rollup_prev=$(get_nested_string "summary_alerts_stats_history_rollup" "prev_present")
summary_alerts_stats_history_rollup_last_alerts=$(get_nested_number "summary_alerts_stats_history_rollup" "last_avg_alerts")
summary_alerts_stats_history_rollup_last_score=$(get_nested_number "summary_alerts_stats_history_rollup" "last_avg_score")
summary_alerts_stats_history_rollup_prev_alerts=$(get_nested_number "summary_alerts_stats_history_rollup" "prev_avg_alerts")
summary_alerts_stats_history_rollup_prev_score=$(get_nested_number "summary_alerts_stats_history_rollup" "prev_avg_score")
summary_alerts_stats_history_rollup_delta_alerts=$(get_nested_number "summary_alerts_stats_history_rollup" "delta_alerts")
summary_alerts_stats_history_rollup_delta_score=$(get_nested_number "summary_alerts_stats_history_rollup" "delta_score")
summary_alerts_stats_history_rollup_result=$(get_nested_string "summary_alerts_stats_history_rollup" "result")
summary_alerts_stats_history_rollup_json_result=$(get_nested_string "summary_alerts_stats_history_rollup" "json_result")
summary_alerts_stats_history_rollup_validate=$(get_nested_string "summary_alerts_stats_history_rollup" "validate")
summary_alerts_stats_history_rollup_md_validate=$(get_nested_string "summary_alerts_stats_history_rollup" "md_validate")
summary_alerts_stats_history_rollup_html_validate=$(get_nested_string "summary_alerts_stats_history_rollup" "html_validate")
summary_alerts_stats_history_rollup_score_value=$(get_nested_number "summary_alerts_stats_history_rollup_score" "score")
summary_alerts_stats_history_rollup_score_result=$(get_nested_string "summary_alerts_stats_history_rollup_score" "result")
summary_alerts_stats_history_rollup_score_json_result=$(get_nested_string "summary_alerts_stats_history_rollup_score" "json_result")
summary_alerts_stats_history_rollup_score_validate=$(get_nested_string "summary_alerts_stats_history_rollup_score" "validate")
summary_alerts_stats_history_rollup_score_md_validate=$(get_nested_string "summary_alerts_stats_history_rollup_score" "md_validate")
summary_alerts_stats_history_rollup_score_html_validate=$(get_nested_string "summary_alerts_stats_history_rollup_score" "html_validate")
summary_alerts_stats_history_rollup_bundle_files=$(get_nested_number "summary_alerts_stats_history_rollup_bundle" "files")
summary_alerts_stats_history_rollup_bundle_missing=$(get_nested_number "summary_alerts_stats_history_rollup_bundle" "missing_count")
summary_alerts_stats_history_rollup_bundle_result=$(get_nested_string "summary_alerts_stats_history_rollup_bundle" "result")
summary_alerts_stats_history_rollup_bundle_validate=$(get_nested_string "summary_alerts_stats_history_rollup_bundle" "validate")
summary_alerts_stats_history_rollup_overview_result=$(get_nested_string "summary_alerts_stats_history_rollup_overview" "result")
summary_alerts_stats_history_rollup_overview_rollup=$(get_nested_string "summary_alerts_stats_history_rollup_overview" "rollup_result")
summary_alerts_stats_history_rollup_overview_score=$(get_nested_string "summary_alerts_stats_history_rollup_overview" "score_result")
summary_alerts_stats_history_rollup_overview_bundle=$(get_nested_string "summary_alerts_stats_history_rollup_overview" "bundle_validate")
summary_alerts_stats_history_rollup_overview_json=$(get_nested_string "summary_alerts_stats_history_rollup_overview" "json_result")
summary_alerts_stats_history_rollup_overview_validate=$(get_nested_string "summary_alerts_stats_history_rollup_overview" "validate")
summary_alerts_stats_history_rollup_history_entries=$(get_section_number "summary_alerts_stats_history_rollup_history" "entries")
summary_alerts_stats_history_rollup_history_date=$(get_section_string "summary_alerts_stats_history_rollup_history" "last_date")
summary_alerts_stats_history_rollup_history_delta_alerts=$(get_section_number "summary_alerts_stats_history_rollup_history" "last_delta_alerts")
summary_alerts_stats_history_rollup_history_delta_score=$(get_section_number "summary_alerts_stats_history_rollup_history" "last_delta_score")
summary_alerts_stats_history_rollup_history_score=$(get_section_number "summary_alerts_stats_history_rollup_history" "last_score")
summary_alerts_stats_history_rollup_history_result=$(get_section_string "summary_alerts_stats_history_rollup_history" "result")
summary_alerts_stats_history_rollup_history_validate=$(get_section_string "summary_alerts_stats_history_rollup_history" "validate")
summary_alerts_stats_history_rollup_history_md_validate=$(get_section_string "summary_alerts_stats_history_rollup_history" "md_validate")
summary_alerts_stats_history_rollup_history_html_validate=$(get_section_string "summary_alerts_stats_history_rollup_history" "html_validate")
summary_alerts_stats_history_rollup_trend_entries=$(get_section_number "summary_alerts_stats_history_rollup_trend" "entries")
summary_alerts_stats_history_rollup_trend_avg_delta_alerts=$(get_section_number "summary_alerts_stats_history_rollup_trend" "avg_delta_alerts")
summary_alerts_stats_history_rollup_trend_avg_delta_score=$(get_section_number "summary_alerts_stats_history_rollup_trend" "avg_delta_score")
summary_alerts_stats_history_rollup_trend_avg_score=$(get_section_number "summary_alerts_stats_history_rollup_trend" "avg_score")
summary_alerts_stats_history_rollup_trend_warn_rollup=$(get_section_number "summary_alerts_stats_history_rollup_trend" "warn_rollup")
summary_alerts_stats_history_rollup_trend_warn_score=$(get_section_number "summary_alerts_stats_history_rollup_trend" "warn_score")
summary_alerts_stats_history_rollup_trend_result=$(get_section_string "summary_alerts_stats_history_rollup_trend" "result")
summary_alerts_stats_history_rollup_trend_validate=$(get_section_string "summary_alerts_stats_history_rollup_trend" "validate")
summary_alerts_stats_history_rollup_trend_md_validate=$(get_section_string "summary_alerts_stats_history_rollup_trend" "md_validate")
summary_alerts_stats_history_rollup_trend_html_validate=$(get_section_string "summary_alerts_stats_history_rollup_trend" "html_validate")
summary_alerts_stats_trend_avg_alerts=$(get_nested_number "summary_alerts_stats_trend" "avg_alerts")
summary_alerts_stats_trend_avg_score=$(get_nested_number "summary_alerts_stats_trend" "avg_bundle_score")
summary_alerts_stats_trend_warn=$(get_nested_number "summary_alerts_stats_trend" "warn")
summary_alerts_stats_trend_result=$(get_nested_string "summary_alerts_stats_trend" "result")
summary_alerts_stats_delta_alerts=$(get_nested_number "summary_alerts_stats_delta" "alerts_delta")
summary_alerts_stats_delta_score=$(get_nested_number "summary_alerts_stats_delta" "score_delta")
summary_alerts_stats_delta_result=$(get_nested_string "summary_alerts_stats_delta" "result")
summary_alerts_stats_report_result=$(get_nested_string "summary_alerts_stats_report" "result")
summary_alerts_stats_report_json_result=$(get_nested_string "summary_alerts_stats_report" "json_result")
summary_alerts_stats_report_md_validate=$(get_nested_string "summary_alerts_stats_report" "md_validate")
summary_alerts_stats_report_html_validate=$(get_nested_string "summary_alerts_stats_report" "html_validate")
summary_alerts_stats_export_validate=$(get_nested_string "summary_alerts_stats_export" "validate")
summary_alerts_items_avg_total=$(get_nested_number "summary_alerts_items_trend" "avg_total_items")
summary_alerts_items_avg_unique=$(get_nested_number "summary_alerts_items_trend" "avg_unique_items")
summary_alerts_items_warn=$(get_nested_number "summary_alerts_items_trend" "warn")
summary_alerts_items_result=$(get_nested_string "summary_alerts_items_trend" "result")
summary_alerts_items_delta_total=$(get_nested_number "summary_alerts_items_delta" "delta_total_items")
summary_alerts_items_delta_unique=$(get_nested_number "summary_alerts_items_delta" "delta_unique_items")
summary_alerts_items_delta_result=$(get_nested_string "summary_alerts_items_delta" "result")
summary_alerts_items_delta_top_changed=$(get_nested_string "summary_alerts_items_delta" "top_text_changed")
summary_alerts_items_delta_mode_changed=$(get_nested_string "summary_alerts_items_delta" "items_mode_changed")
summary_alerts_items_report_mode=$(get_nested_string "summary_alerts_items_report" "items_mode")
summary_alerts_items_report_top=$(get_nested_string "summary_alerts_items_report" "items_top")
summary_alerts_items_report_result=$(get_nested_string "summary_alerts_items_report" "result")
summary_alerts_items_overview_mode=$(get_nested_string "summary_alerts_items_overview" "items_mode")
summary_alerts_items_overview_top=$(get_nested_string "summary_alerts_items_overview" "items_top")
summary_alerts_items_overview_result=$(get_nested_string "summary_alerts_items_overview" "result")
summary_bundle_result=$(get_section_string "summary_bundle" "result")
summary_bundle_missing=$(get_section_number "summary_bundle" "missing")
summary_bundle_index_entries=$(get_section_number "summary_bundle" "entries")
summary_bundle_index_avg=$(get_section_number "summary_bundle" "avg_files")
summary_bundle_index_warn=$(get_section_number "summary_bundle" "warn")
summary_bundle_index_result=$(get_section_string "index_trend" "result")
summary_bundle_index_delta=$(get_section_number "index_delta" "delta_files")
summary_bundle_index_delta_result=$(get_section_string "index_delta" "result")
summary_bundle_index_last_files=$(get_section_number "index_delta" "last_files")
summary_bundle_index_prev_files=$(get_section_number "index_delta" "previous_files")
summary_bundle_index_overview_result=$(get_section_string "index_overview" "result")
summary_bundle_index_overview_trend=$(get_section_string "index_overview" "trend_result")
summary_bundle_index_overview_delta=$(get_section_string "index_overview" "delta_result")
summary_bundle_index_score_value=$(get_section_number "index_score" "score")
summary_bundle_index_score_result=$(get_section_string "index_score" "result")
summary_bundle_index_score_warn=$(get_section_number "index_score" "warn")
summary_bundle_index_score_delta=$(get_section_number "index_score" "delta_files")

{
	echo "overall: ${overall:-unknown}"
	echo "gate: ${gate:-unknown}"
	echo "gate_validate: ${gate_validate:-unknown}"
	echo "gate_trend_warn: ${gate_warn:-0}"
	echo "gate_trend_fail: ${gate_fail:-0}"
	echo "check_failures: ${check_failures:-0}"
	echo "check_ignored: ${check_ignored:-0}"
	echo "check_missing: ${check_missing:-0}"
	echo "check_fail_rate: ${check_fail_rate:-0}"
	echo "check_ignored_rate: ${check_ignored_rate:-0}"
	echo "build_system: ${sys_done:-0}/${sys_total:-0}"
	echo "mini_system: ${mini_done:-0}/${mini_total:-0}"
	echo "queue_ok: ${queue_ok:-0}"
	echo "queue_fail: ${queue_fail:-0}"
	echo "queue_timeout: ${queue_timeout:-0}"
	echo "toolchain_session: ${toolchain_session:-unknown}"
	echo "preflight_gate: ${preflight_gate:-unknown}"
	echo "preflight_gate_validate: ${preflight_gate_validate:-unknown}"
	echo "preflight_gate_trend_warn: ${pre_gate_warn:-0}"
	echo "preflight_gate_trend_fail: ${pre_gate_fail:-0}"
	echo "preflight_avg_warns: ${pre_avg_warns:-0}"
	echo "summary_alerts: ${summary_alerts_result:-unknown} (${summary_alerts_count:-0})"
	echo "summary_alerts_avg: ${summary_alerts_avg:-0}"
	echo "summary_alerts_stats: ${summary_alerts_stats_result:-unknown} total=${summary_alerts_stats_total:-0} gate=${summary_alerts_stats_gate:-0} checks=${summary_alerts_stats_checks:-0} preflight=${summary_alerts_stats_preflight:-0} bundle=${summary_alerts_stats_bundle:-0} alerts_items=${summary_alerts_stats_items:-0} other=${summary_alerts_stats_other:-0} bundle_score=${summary_alerts_stats_bundle_score:-0} bundle_score_result=${summary_alerts_stats_bundle_score_result:-unknown}"
	echo "summary_alerts_stats_history_report: ${summary_alerts_stats_history_result:-unknown} entries=${summary_alerts_stats_history_entries:-0} last_alerts=${summary_alerts_stats_history_last_alerts:-0} last_score=${summary_alerts_stats_history_last_score:-0} json=${summary_alerts_stats_history_json_result:-unknown} validate=${summary_alerts_stats_history_validate:-unknown} md_validate=${summary_alerts_stats_history_md_validate:-unknown} html_validate=${summary_alerts_stats_history_html_validate:-unknown}"
	echo "summary_alerts_stats_history_table: ${summary_alerts_stats_history_table_result:-unknown} entries=${summary_alerts_stats_history_table_entries:-0} validate=${summary_alerts_stats_history_table_validate:-unknown} md_validate=${summary_alerts_stats_history_table_md_validate:-unknown} html_validate=${summary_alerts_stats_history_table_html_validate:-unknown}"
	echo "summary_alerts_stats_history_score: ${summary_alerts_stats_history_score_result:-unknown} score=${summary_alerts_stats_history_score_value:-0} validate=${summary_alerts_stats_history_score_validate:-unknown}"
	echo "summary_alerts_stats_history_anomalies: ${summary_alerts_stats_history_anomalies_result:-unknown} entries=${summary_alerts_stats_history_anomalies_entries:-0} anomalies=${summary_alerts_stats_history_anomalies_count:-0} max_alerts_delta=${summary_alerts_stats_history_anomalies_max_alerts:-0} min_score_delta=${summary_alerts_stats_history_anomalies_min_score:-0} json=${summary_alerts_stats_history_anomalies_json_result:-unknown} validate=${summary_alerts_stats_history_anomalies_validate:-unknown} md_validate=${summary_alerts_stats_history_anomalies_md_validate:-unknown} html_validate=${summary_alerts_stats_history_anomalies_html_validate:-unknown}"
	echo "summary_alerts_stats_history_rollup: ${summary_alerts_stats_history_rollup_result:-unknown} entries=${summary_alerts_stats_history_rollup_entries:-0} window=${summary_alerts_stats_history_rollup_window:-0} prev=${summary_alerts_stats_history_rollup_prev:-false} last_avg_alerts=${summary_alerts_stats_history_rollup_last_alerts:-0} last_avg_score=${summary_alerts_stats_history_rollup_last_score:-0} prev_avg_alerts=${summary_alerts_stats_history_rollup_prev_alerts:-0} prev_avg_score=${summary_alerts_stats_history_rollup_prev_score:-0} delta_alerts=${summary_alerts_stats_history_rollup_delta_alerts:-0} delta_score=${summary_alerts_stats_history_rollup_delta_score:-0} json=${summary_alerts_stats_history_rollup_json_result:-unknown} validate=${summary_alerts_stats_history_rollup_validate:-unknown} md_validate=${summary_alerts_stats_history_rollup_md_validate:-unknown} html_validate=${summary_alerts_stats_history_rollup_html_validate:-unknown}"
	echo "summary_alerts_stats_history_rollup_score: ${summary_alerts_stats_history_rollup_score_result:-unknown} score=${summary_alerts_stats_history_rollup_score_value:-0} json=${summary_alerts_stats_history_rollup_score_json_result:-unknown} validate=${summary_alerts_stats_history_rollup_score_validate:-unknown} md_validate=${summary_alerts_stats_history_rollup_score_md_validate:-unknown} html_validate=${summary_alerts_stats_history_rollup_score_html_validate:-unknown}"
	echo "summary_alerts_stats_history_rollup_bundle: ${summary_alerts_stats_history_rollup_bundle_result:-unknown} files=${summary_alerts_stats_history_rollup_bundle_files:-0} missing=${summary_alerts_stats_history_rollup_bundle_missing:-0} validate=${summary_alerts_stats_history_rollup_bundle_validate:-unknown}"
	echo "summary_alerts_stats_history_rollup_overview: ${summary_alerts_stats_history_rollup_overview_result:-unknown} rollup=${summary_alerts_stats_history_rollup_overview_rollup:-unknown} score=${summary_alerts_stats_history_rollup_overview_score:-unknown} bundle=${summary_alerts_stats_history_rollup_overview_bundle:-unknown} json=${summary_alerts_stats_history_rollup_overview_json:-unknown} validate=${summary_alerts_stats_history_rollup_overview_validate:-unknown}"
	echo "summary_alerts_stats_history_rollup_history: ${summary_alerts_stats_history_rollup_history_result:-unknown} entries=${summary_alerts_stats_history_rollup_history_entries:-0} last_date=${summary_alerts_stats_history_rollup_history_date:-unknown} last_delta_alerts=${summary_alerts_stats_history_rollup_history_delta_alerts:-0} last_delta_score=${summary_alerts_stats_history_rollup_history_delta_score:-0} last_score=${summary_alerts_stats_history_rollup_history_score:-0} validate=${summary_alerts_stats_history_rollup_history_validate:-unknown} md_validate=${summary_alerts_stats_history_rollup_history_md_validate:-unknown} html_validate=${summary_alerts_stats_history_rollup_history_html_validate:-unknown}"
	echo "summary_alerts_stats_history_rollup_trend: ${summary_alerts_stats_history_rollup_trend_result:-unknown} entries=${summary_alerts_stats_history_rollup_trend_entries:-0} avg_delta_alerts=${summary_alerts_stats_history_rollup_trend_avg_delta_alerts:-0} avg_delta_score=${summary_alerts_stats_history_rollup_trend_avg_delta_score:-0} avg_score=${summary_alerts_stats_history_rollup_trend_avg_score:-0} warn_rollup=${summary_alerts_stats_history_rollup_trend_warn_rollup:-0} warn_score=${summary_alerts_stats_history_rollup_trend_warn_score:-0} validate=${summary_alerts_stats_history_rollup_trend_validate:-unknown} md_validate=${summary_alerts_stats_history_rollup_trend_md_validate:-unknown} html_validate=${summary_alerts_stats_history_rollup_trend_html_validate:-unknown}"
	echo "summary_alerts_stats_trend: ${summary_alerts_stats_trend_result:-unknown} avg_alerts=${summary_alerts_stats_trend_avg_alerts:-0} avg_bundle_score=${summary_alerts_stats_trend_avg_score:-0} warn=${summary_alerts_stats_trend_warn:-0}"
	echo "summary_alerts_stats_delta: ${summary_alerts_stats_delta_result:-unknown} alerts_delta=${summary_alerts_stats_delta_alerts:-0} score_delta=${summary_alerts_stats_delta_score:-0}"
	echo "summary_alerts_stats_report: ${summary_alerts_stats_report_result:-unknown} json=${summary_alerts_stats_report_json_result:-unknown} md_validate=${summary_alerts_stats_report_md_validate:-unknown} html_validate=${summary_alerts_stats_report_html_validate:-unknown}"
	echo "summary_alerts_stats_export: ${summary_alerts_stats_export_validate:-unknown}"
	echo "summary_alerts_items_trend: ${summary_alerts_items_result:-unknown} avg_total=${summary_alerts_items_avg_total:-0} avg_unique=${summary_alerts_items_avg_unique:-0} warn=${summary_alerts_items_warn:-0}"
	echo "summary_alerts_items_delta: ${summary_alerts_items_delta_result:-unknown} total=${summary_alerts_items_delta_total:-0} unique=${summary_alerts_items_delta_unique:-0} top_changed=${summary_alerts_items_delta_top_changed:-false} mode_changed=${summary_alerts_items_delta_mode_changed:-false}"
	echo "summary_alerts_items_report: ${summary_alerts_items_report_result:-unknown} mode=${summary_alerts_items_report_mode:-unknown} top=${summary_alerts_items_report_top:-none}"
	echo "summary_alerts_items_overview: ${summary_alerts_items_overview_result:-unknown} mode=${summary_alerts_items_overview_mode:-unknown} top=${summary_alerts_items_overview_top:-none}"
	echo "summary_bundle: ${summary_bundle_result:-unknown} (missing=${summary_bundle_missing:-0})"
	echo "summary_bundle_index_trend: ${summary_bundle_index_result:-unknown} entries=${summary_bundle_index_entries:-0} avg_files=${summary_bundle_index_avg:-0} warn=${summary_bundle_index_warn:-0}"
	echo "summary_bundle_index_delta: ${summary_bundle_index_delta_result:-unknown} delta=${summary_bundle_index_delta:-0} last=${summary_bundle_index_last_files:-0} prev=${summary_bundle_index_prev_files:-0}"
	echo "summary_bundle_index_overview: ${summary_bundle_index_overview_result:-unknown} trend=${summary_bundle_index_overview_trend:-unknown} delta=${summary_bundle_index_overview_delta:-unknown}"
	echo "summary_bundle_index_score: ${summary_bundle_index_score_result:-unknown} score=${summary_bundle_index_score_value:-0} warn=${summary_bundle_index_score_warn:-0} delta=${summary_bundle_index_score_delta:-0}"
} >>"$OUT_TXT"

result="ok"
if [ "$overall" = "warn" ] || [ "$gate" = "warn" ] || [ "$gate_validate" = "warn" ]; then
	result="warn"
fi
echo "result: $result" >>"$OUT_TXT"

echo "[OK] Build summary report generated: $OUT_TXT"
