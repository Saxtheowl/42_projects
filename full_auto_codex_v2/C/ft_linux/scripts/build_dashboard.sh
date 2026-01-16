#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
STATUS_FILE="$REPORT_DIR/status_assessment.txt"
CHECK_GATE_FILE="$REPORT_DIR/build_check_gate.txt"
CHECK_REPORT_FILE="$REPORT_DIR/build_check_report.txt"
CHECK_STATS_FILE="$REPORT_DIR/build_check_stats.txt"
CHECK_REG_FILE="$REPORT_DIR/build_check_regressions.txt"
CHECK_REG_SUMMARY_FILE="$REPORT_DIR/build_check_regressions_summary.txt"
TOOLCHAIN_SESSION_FILE="$REPORT_DIR/build_toolchain_session_report.txt"
PREFLIGHT_FILE="$REPORT_DIR/preflight.txt"
PREFLIGHT_TREND_FILE="$REPORT_DIR/preflight_trend.txt"
PREFLIGHT_GATE_FILE="$REPORT_DIR/build_preflight_gate.txt"
PREFLIGHT_GATE_TREND_FILE="$REPORT_DIR/build_preflight_gate_trend.txt"
BUILD_GATE_TREND_FILE="$REPORT_DIR/build_gate_trend.txt"
BUILD_SUMMARY_TREND_FILE="$REPORT_DIR/build_summary_trend.txt"
BUILD_SUMMARY_ALERTS_FILE="$REPORT_DIR/build_summary_alerts.txt"
BUILD_SUMMARY_ALERTS_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_validate.txt"
BUILD_SUMMARY_ALERTS_TREND_FILE="$REPORT_DIR/build_summary_alerts_trend.txt"
BUILD_SUMMARY_ALERTS_STATS_FILE="$REPORT_DIR/build_summary_alerts_stats.txt"
BUILD_SUMMARY_ALERTS_STATS_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_report.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_report_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_MD_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_report_md_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_HTML_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_report_html_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_table.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_table_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_MD_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_table_md_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_HTML_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_table_html_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_SCORE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_score.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_SCORE_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_score_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_FILE="$REPORT_DIR/build_summary_alerts_stats_history_anomalies.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_anomalies_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_MD_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_anomalies_md_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_HTML_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_anomalies_html_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_SCORE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_SCORE_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_BUNDLE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_BUNDLE_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_MD_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_md_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_HTML_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_html_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_MD_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_md_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_HTML_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_html_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_MD_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend_md_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_HTML_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend_html_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_TREND_FILE="$REPORT_DIR/build_summary_alerts_stats_trend.txt"
BUILD_SUMMARY_ALERTS_STATS_TREND_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_trend_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_DELTA_FILE="$REPORT_DIR/build_summary_alerts_stats_delta.txt"
BUILD_SUMMARY_ALERTS_STATS_DELTA_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_delta_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_report.txt"
BUILD_SUMMARY_ALERTS_STATS_REPORT_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_report_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_REPORT_JSON_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_report_json_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_REPORT_MD_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_report_md_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_HTML_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_html_validate.txt"
BUILD_SUMMARY_ALERTS_STATS_EXPORT_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_export_validate.txt"
BUILD_SUMMARY_BUNDLE_VALIDATE_FILE="$REPORT_DIR/build_summary_bundle_validate.txt"
BUILD_SUMMARY_BUNDLE_INDEX_TREND_FILE="$REPORT_DIR/build_summary_bundle_index_trend.txt"
BUILD_SUMMARY_BUNDLE_INDEX_TREND_VALIDATE_FILE="$REPORT_DIR/build_summary_bundle_index_trend_validate.txt"
BUILD_SUMMARY_BUNDLE_INDEX_HISTORY_VALIDATE_FILE="$REPORT_DIR/build_summary_bundle_index_history_validate.txt"
BUILD_SUMMARY_BUNDLE_INDEX_DELTA_FILE="$REPORT_DIR/build_summary_bundle_index_delta.txt"
BUILD_SUMMARY_BUNDLE_INDEX_DELTA_VALIDATE_FILE="$REPORT_DIR/build_summary_bundle_index_delta_validate.txt"
BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_FILE="$REPORT_DIR/build_summary_bundle_index_overview.txt"
BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_VALIDATE_FILE="$REPORT_DIR/build_summary_bundle_index_overview_validate.txt"
BUILD_SUMMARY_BUNDLE_INDEX_SCORE_FILE="$REPORT_DIR/build_summary_bundle_index_score.txt"
BUILD_SUMMARY_BUNDLE_INDEX_SCORE_VALIDATE_FILE="$REPORT_DIR/build_summary_bundle_index_score_validate.txt"
BUILD_SUMMARY_ALERTS_ITEMS_FILE="$REPORT_DIR/build_summary_alerts_items.txt"
BUILD_SUMMARY_ALERTS_ITEMS_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_items_validate.txt"
BUILD_SUMMARY_ALERTS_ITEMS_TREND_FILE="$REPORT_DIR/build_summary_alerts_items_trend.txt"
BUILD_SUMMARY_ALERTS_ITEMS_TREND_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_items_trend_validate.txt"
BUILD_SUMMARY_ALERTS_ITEMS_HISTORY_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_items_history_validate.txt"
BUILD_SUMMARY_ALERTS_ITEMS_DELTA_FILE="$REPORT_DIR/build_summary_alerts_items_delta.txt"
BUILD_SUMMARY_ALERTS_ITEMS_DELTA_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_items_delta_validate.txt"
BUILD_SUMMARY_ALERTS_ITEMS_REPORT_FILE="$REPORT_DIR/build_summary_alerts_items_report.txt"
BUILD_SUMMARY_ALERTS_ITEMS_REPORT_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_items_report_validate.txt"
BUILD_SUMMARY_ALERTS_ITEMS_REPORT_JSON_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_items_report_json_validate.txt"
BUILD_SUMMARY_ALERTS_ITEMS_REPORT_MD_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_items_report_md_validate.txt"
BUILD_SUMMARY_ALERTS_ITEMS_OVERVIEW_FILE="$REPORT_DIR/build_summary_alerts_items_overview.txt"
BUILD_SUMMARY_ALERTS_ITEMS_OVERVIEW_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_items_overview_validate.txt"
OUT_TXT="$REPORT_DIR/build_dashboard.txt"

usage() {
	cat <<EOF
Usage: $0 [--status <file>] [--out <file>]

Genere un tableau de bord a partir de status_assessment.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--status) STATUS_FILE="$2"; shift 2 ;;
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
	echo "build_dashboard generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "status_file: $STATUS_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$STATUS_FILE" ]; then
	echo "result: missing_status" >>"$OUT_TXT"
	echo "status_assessment missing" >>"$OUT_TXT"
	exit 0
fi

overall="ok"
actions=""

while IFS= read -r line || [ -n "$line" ]; do
	case "$line" in
		""|Status*|date:*|Notes:*) continue ;;
	esac
	label=$(printf '%s' "$line" | awk '{print $1}')
	result=$(printf '%s' "$line" | awk '{print $2}')
	if [ "$result" = "missing" ]; then
		overall="warn"
		actions+="- ${label}: generer le rapport manquant\n"
	elif [ "$result" = "warn" ]; then
		overall="warn"
		actions+="- ${label}: verifier les details du rapport\n"
	fi
done <"$STATUS_FILE"

echo "result: $overall" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"
echo "checks:" >>"$OUT_TXT"
if [ -f "$CHECK_GATE_FILE" ]; then
	gate_result=$(grep -E '^result:' "$CHECK_GATE_FILE" | awk '{print $2}')
	failures=$(grep -E '^check_failures:' "$CHECK_GATE_FILE" | awk '{print $2}')
	ignored=$(grep -E '^check_fail_ignored:' "$CHECK_GATE_FILE" | awk '{print $2}')
	missing=$(grep -E '^check_missing:' "$CHECK_GATE_FILE" | awk '{print $2}')
	echo "- check_gate: ${gate_result:-unknown} (fail=${failures:-0} ignored=${ignored:-0} missing=${missing:-0})" >>"$OUT_TXT"
else
	echo "- check_gate: missing ($CHECK_GATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$CHECK_REPORT_FILE" ]; then
	report_result=$(grep -E '^result:' "$CHECK_REPORT_FILE" | awk '{print $2}')
	report_fail=$(grep -E '^check_failures:' "$CHECK_REPORT_FILE" | awk '{print $2}')
	report_ign=$(grep -E '^check_fail_ignored:' "$CHECK_REPORT_FILE" | awk '{print $2}')
	report_miss=$(grep -E '^check_missing:' "$CHECK_REPORT_FILE" | awk '{print $2}')
	echo "- check_report: ${report_result:-unknown} (fail=${report_fail:-0} ignored=${report_ign:-0} missing=${report_miss:-0})" >>"$OUT_TXT"
else
	echo "- check_report: missing ($CHECK_REPORT_FILE)" >>"$OUT_TXT"
fi
if [ -f "$CHECK_STATS_FILE" ]; then
	stats_fail_rate=$(grep -E '^fail_rate:' "$CHECK_STATS_FILE" | head -n 1 | awk '{print $2}')
	stats_ignored_rate=$(grep -E '^ignored_rate:' "$CHECK_STATS_FILE" | head -n 1 | awk '{print $2}')
	echo "- check_stats: fail_rate=${stats_fail_rate:-0} ignored_rate=${stats_ignored_rate:-0}" >>"$OUT_TXT"
else
	echo "- check_stats: missing ($CHECK_STATS_FILE)" >>"$OUT_TXT"
fi
if [ -f "$CHECK_REG_FILE" ]; then
	reg_result=$(grep -E '^result:' "$CHECK_REG_FILE" | awk '{print $2}')
	reg_count=$(grep -E '^regressions:' "$CHECK_REG_FILE" | head -n 1 | awk '{print $2}')
	rec_count=$(grep -E '^recoveries:' "$CHECK_REG_FILE" | head -n 1 | awk '{print $2}')
	echo "- check_regressions: ${reg_result:-unknown} (reg=${reg_count:-0} rec=${rec_count:-0})" >>"$OUT_TXT"
else
	echo "- check_regressions: missing ($CHECK_REG_FILE)" >>"$OUT_TXT"
fi
if [ -f "$CHECK_REG_SUMMARY_FILE" ]; then
	sum_reg=$(grep -E '^regressions:' "$CHECK_REG_SUMMARY_FILE" | head -n 1 | awk '{print $2}')
	sum_rec=$(grep -E '^recoveries:' "$CHECK_REG_SUMMARY_FILE" | head -n 1 | awk '{print $2}')
	sum_total=$(grep -E '^total_compared:' "$CHECK_REG_SUMMARY_FILE" | head -n 1 | awk '{print $2}')
	sum_worst=$(grep -E '^worst_group:' "$CHECK_REG_SUMMARY_FILE" | head -n 1 | awk '{print $2}')
	sum_rate=$(grep -E '^worst_rate:' "$CHECK_REG_SUMMARY_FILE" | head -n 1 | awk '{print $2}')
	echo "- check_regressions_summary: reg=${sum_reg:-0} rec=${sum_rec:-0} total=${sum_total:-0} worst=${sum_worst:-none} rate=${sum_rate:-0}" >>"$OUT_TXT"
else
	echo "- check_regressions_summary: missing ($CHECK_REG_SUMMARY_FILE)" >>"$OUT_TXT"
fi
if [ -f "$TOOLCHAIN_SESSION_FILE" ]; then
	session_result=$(grep -E '^result:' "$TOOLCHAIN_SESSION_FILE" | head -n 1 | awk '{print $2}')
	preflight_result=$(grep -E '^preflight_result:' "$TOOLCHAIN_SESSION_FILE" | head -n 1 | awk '{print $2}')
	toolchain_result=$(grep -E '^toolchain_result:' "$TOOLCHAIN_SESSION_FILE" | head -n 1 | awk '{print $2}')
	echo "- toolchain_session: ${session_result:-unknown} (preflight=${preflight_result:-unknown} toolchain=${toolchain_result:-unknown})" >>"$OUT_TXT"
else
	echo "- toolchain_session: missing ($TOOLCHAIN_SESSION_FILE)" >>"$OUT_TXT"
fi
if [ -f "$PREFLIGHT_FILE" ]; then
	preflight_status=$(grep -E '^result:' "$PREFLIGHT_FILE" | head -n 1 | awk '{print $2}')
	preflight_warns=$(grep -E '^warn_count:' "$PREFLIGHT_FILE" | head -n 1 | awk '{print $2}')
	echo "- preflight: ${preflight_status:-unknown} (warns=${preflight_warns:-0})" >>"$OUT_TXT"
else
	echo "- preflight: missing ($PREFLIGHT_FILE)" >>"$OUT_TXT"
fi
if [ -f "$PREFLIGHT_TREND_FILE" ]; then
	trend_entries=$(grep -E '^entries:' "$PREFLIGHT_TREND_FILE" | head -n 1 | awk '{print $2}')
	trend_warns=$(grep -E '^warn:' "$PREFLIGHT_TREND_FILE" | head -n 1 | awk '{print $2}')
	trend_avg=$(grep -E '^avg_warns:' "$PREFLIGHT_TREND_FILE" | head -n 1 | awk '{print $2}')
	echo "- preflight_trend: entries=${trend_entries:-0} warn=${trend_warns:-0} avg_warns=${trend_avg:-0}" >>"$OUT_TXT"
else
	echo "- preflight_trend: missing ($PREFLIGHT_TREND_FILE)" >>"$OUT_TXT"
fi
if [ -f "$PREFLIGHT_GATE_FILE" ]; then
	preflight_gate=$(grep -E '^result:' "$PREFLIGHT_GATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- preflight_gate: ${preflight_gate:-unknown}" >>"$OUT_TXT"
else
	echo "- preflight_gate: missing ($PREFLIGHT_GATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$PREFLIGHT_GATE_TREND_FILE" ]; then
	gate_entries=$(grep -E '^entries:' "$PREFLIGHT_GATE_TREND_FILE" | head -n 1 | awk '{print $2}')
	gate_warn=$(grep -E '^warn:' "$PREFLIGHT_GATE_TREND_FILE" | head -n 1 | awk '{print $2}')
	gate_fail=$(grep -E '^fail:' "$PREFLIGHT_GATE_TREND_FILE" | head -n 1 | awk '{print $2}')
	echo "- preflight_gate_trend: entries=${gate_entries:-0} warn=${gate_warn:-0} fail=${gate_fail:-0}" >>"$OUT_TXT"
else
	echo "- preflight_gate_trend: missing ($PREFLIGHT_GATE_TREND_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_GATE_TREND_FILE" ]; then
	build_gate_entries=$(grep -E '^entries:' "$BUILD_GATE_TREND_FILE" | head -n 1 | awk '{print $2}')
	build_gate_warn=$(grep -E '^warn:' "$BUILD_GATE_TREND_FILE" | head -n 1 | awk '{print $2}')
	build_gate_fail=$(grep -E '^fail:' "$BUILD_GATE_TREND_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_gate_trend: entries=${build_gate_entries:-0} warn=${build_gate_warn:-0} fail=${build_gate_fail:-0}" >>"$OUT_TXT"
else
	echo "- build_gate_trend: missing ($BUILD_GATE_TREND_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_TREND_FILE" ]; then
	summary_entries=$(grep -E '^entries:' "$BUILD_SUMMARY_TREND_FILE" | head -n 1 | awk '{print $2}')
	summary_warn=$(grep -E '^warn:' "$BUILD_SUMMARY_TREND_FILE" | head -n 1 | awk '{print $2}')
	summary_fail=$(grep -E '^fail:' "$BUILD_SUMMARY_TREND_FILE" | head -n 1 | awk '{print $2}')
	summary_avg_fail=$(grep -E '^avg_check_failures:' "$BUILD_SUMMARY_TREND_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_trend: entries=${summary_entries:-0} warn=${summary_warn:-0} fail=${summary_fail:-0} avg_fail=${summary_avg_fail:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_trend: missing ($BUILD_SUMMARY_TREND_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_FILE" ]; then
	alerts_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts: ${alerts_result:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts: missing ($BUILD_SUMMARY_ALERTS_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_VALIDATE_FILE" ]; then
	alerts_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_validate: ${alerts_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_validate: missing ($BUILD_SUMMARY_ALERTS_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_TREND_FILE" ]; then
	alerts_entries=$(grep -E '^entries:' "$BUILD_SUMMARY_ALERTS_TREND_FILE" | head -n 1 | awk '{print $2}')
	alerts_avg=$(grep -E '^avg_alerts:' "$BUILD_SUMMARY_ALERTS_TREND_FILE" | head -n 1 | awk '{print $2}')
	alerts_warn=$(grep -E '^warn:' "$BUILD_SUMMARY_ALERTS_TREND_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_trend: entries=${alerts_entries:-0} avg=${alerts_avg:-0} warn=${alerts_warn:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_trend: missing ($BUILD_SUMMARY_ALERTS_TREND_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_FILE" ]; then
	alerts_stats_total=$(grep -E '^alerts_total:' "$BUILD_SUMMARY_ALERTS_STATS_FILE" | head -n 1 | awk '{print $2}')
	alerts_stats_gate=$(grep -E '^gate:' "$BUILD_SUMMARY_ALERTS_STATS_FILE" | head -n 1 | awk '{print $2}')
	alerts_stats_checks=$(grep -E '^checks:' "$BUILD_SUMMARY_ALERTS_STATS_FILE" | head -n 1 | awk '{print $2}')
	alerts_stats_preflight=$(grep -E '^preflight:' "$BUILD_SUMMARY_ALERTS_STATS_FILE" | head -n 1 | awk '{print $2}')
	alerts_stats_bundle=$(grep -E '^bundle:' "$BUILD_SUMMARY_ALERTS_STATS_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats: total=${alerts_stats_total:-0} gate=${alerts_stats_gate:-0} checks=${alerts_stats_checks:-0} preflight=${alerts_stats_preflight:-0} bundle=${alerts_stats_bundle:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats: missing ($BUILD_SUMMARY_ALERTS_STATS_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_VALIDATE_FILE" ]; then
	alerts_stats_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_validate: ${alerts_stats_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_FILE" ]; then
	history_entries=$(grep -E '^entries:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_FILE" | head -n 1 | awk '{print $2}')
	history_last_alerts=$(grep -E '^last_alerts_total:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_FILE" | head -n 1 | awk '{print $2}')
	history_last_score=$(grep -E '^last_bundle_score:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_FILE" | head -n 1 | awk '{print $2}')
	history_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_report: ${history_result:-unknown} entries=${history_entries:-0} last_alerts=${history_last_alerts:-0} last_score=${history_last_score:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_report: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_VALIDATE_FILE" ]; then
	history_report_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_report_validate: ${history_report_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_report_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_MD_VALIDATE_FILE" ]; then
	history_report_md_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_MD_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_report_md_validate: ${history_report_md_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_report_md_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_MD_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_HTML_VALIDATE_FILE" ]; then
	history_report_html_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_HTML_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_report_html_validate: ${history_report_html_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_report_html_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_REPORT_HTML_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_FILE" ]; then
	history_table_entries=$(grep -E '^entries:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_FILE" | head -n 1 | awk '{print $2}')
	history_table_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_table: ${history_table_result:-unknown} entries=${history_table_entries:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_table: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_VALIDATE_FILE" ]; then
	history_table_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_table_validate: ${history_table_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_table_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_MD_VALIDATE_FILE" ]; then
	history_table_md_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_MD_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_table_md_validate: ${history_table_md_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_table_md_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_MD_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_HTML_VALIDATE_FILE" ]; then
	history_table_html_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_HTML_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_table_html_validate: ${history_table_html_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_table_html_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_TABLE_HTML_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_SCORE_FILE" ]; then
	history_score=$(grep -E '^score:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_SCORE_FILE" | head -n 1 | awk '{print $2}')
	history_score_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_SCORE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_score: ${history_score_result:-unknown} score=${history_score:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_score: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_SCORE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_SCORE_VALIDATE_FILE" ]; then
	history_score_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_SCORE_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_score_validate: ${history_score_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_score_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_SCORE_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_FILE" ]; then
	history_anomalies=$(grep -E '^anomalies:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_FILE" | head -n 1 | awk '{print $2}')
	history_anomalies_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_anomalies: ${history_anomalies_result:-unknown} anomalies=${history_anomalies:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_anomalies: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_VALIDATE_FILE" ]; then
	history_anomalies_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_anomalies_validate: ${history_anomalies_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_anomalies_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_MD_VALIDATE_FILE" ]; then
	history_anomalies_md_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_MD_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_anomalies_md_validate: ${history_anomalies_md_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_anomalies_md_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_MD_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_HTML_VALIDATE_FILE" ]; then
	history_anomalies_html_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_HTML_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_anomalies_html_validate: ${history_anomalies_html_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_anomalies_html_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ANOMALIES_HTML_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_FILE" ]; then
	history_rollup_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_FILE" | head -n 1 | awk '{print $2}')
	history_rollup_window=$(grep -E '^window:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_FILE" | head -n 1 | awk '{print $2}')
	history_rollup_delta_alerts=$(grep -E '^delta_alerts:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_FILE" | head -n 1 | awk '{print $2}')
	history_rollup_delta_score=$(grep -E '^delta_score:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup: ${history_rollup_result:-unknown} window=${history_rollup_window:-0} delta_alerts=${history_rollup_delta_alerts:-0} delta_score=${history_rollup_delta_score:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_VALIDATE_FILE" ]; then
	history_rollup_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_validate: ${history_rollup_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_SCORE_FILE" ]; then
	history_rollup_score=$(grep -E '^score:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_SCORE_FILE" | head -n 1 | awk '{print $2}')
	history_rollup_score_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_SCORE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_score: ${history_rollup_score_result:-unknown} score=${history_rollup_score:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_score: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_SCORE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_SCORE_VALIDATE_FILE" ]; then
	history_rollup_score_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_SCORE_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_score_validate: ${history_rollup_score_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_score_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_SCORE_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_BUNDLE_FILE" ]; then
	history_rollup_bundle_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_BUNDLE_FILE" | head -n 1 | awk '{print $2}')
	history_rollup_bundle_files=$(grep -E '^files:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_BUNDLE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_bundle: ${history_rollup_bundle_result:-unknown} files=${history_rollup_bundle_files:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_bundle: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_BUNDLE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_BUNDLE_VALIDATE_FILE" ]; then
	history_rollup_bundle_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_BUNDLE_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_bundle_validate: ${history_rollup_bundle_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_bundle_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_BUNDLE_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_FILE" ]; then
	history_rollup_overview_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_FILE" | head -n 1 | awk '{print $2}')
	history_rollup_overview_score=$(grep -E '^rollup_score:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_overview: ${history_rollup_overview_result:-unknown} score=${history_rollup_overview_score:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_overview: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_VALIDATE_FILE" ]; then
	history_rollup_overview_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_overview_validate: ${history_rollup_overview_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_overview_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_MD_VALIDATE_FILE" ]; then
	history_rollup_overview_md_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_MD_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_overview_md_validate: ${history_rollup_overview_md_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_overview_md_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_MD_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_HTML_VALIDATE_FILE" ]; then
	history_rollup_overview_html_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_HTML_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_overview_html_validate: ${history_rollup_overview_html_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_overview_html_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_OVERVIEW_HTML_VALIDATE_FILE)" >>"$OUT_TXT"
fi

if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_FILE" ]; then
	history_rollup_history_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_FILE" | head -n 1 | awk '{print $2}')
	history_rollup_history_entries=$(grep -E '^entries:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_history: ${history_rollup_history_result:-unknown} entries=${history_rollup_history_entries:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_history: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_FILE)" >>"$OUT_TXT"
fi

if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_VALIDATE_FILE" ]; then
	history_rollup_history_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_history_validate: ${history_rollup_history_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_history_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_VALIDATE_FILE)" >>"$OUT_TXT"
fi

if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_MD_VALIDATE_FILE" ]; then
	history_rollup_history_md_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_MD_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_history_md_validate: ${history_rollup_history_md_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_history_md_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_MD_VALIDATE_FILE)" >>"$OUT_TXT"
fi

if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_HTML_VALIDATE_FILE" ]; then
	history_rollup_history_html_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_HTML_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_history_html_validate: ${history_rollup_history_html_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_history_html_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_HISTORY_HTML_VALIDATE_FILE)" >>"$OUT_TXT"
fi

if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_FILE" ]; then
	history_rollup_trend_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_FILE" | head -n 1 | awk '{print $2}')
	history_rollup_trend_entries=$(grep -E '^entries:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_trend: ${history_rollup_trend_result:-unknown} entries=${history_rollup_trend_entries:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_trend: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_FILE)" >>"$OUT_TXT"
fi

if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_VALIDATE_FILE" ]; then
	history_rollup_trend_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_trend_validate: ${history_rollup_trend_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_trend_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_VALIDATE_FILE)" >>"$OUT_TXT"
fi

if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_MD_VALIDATE_FILE" ]; then
	history_rollup_trend_md_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_MD_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_trend_md_validate: ${history_rollup_trend_md_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_trend_md_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_MD_VALIDATE_FILE)" >>"$OUT_TXT"
fi

if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_HTML_VALIDATE_FILE" ]; then
	history_rollup_trend_html_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_HTML_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_history_rollup_trend_html_validate: ${history_rollup_trend_html_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_history_rollup_trend_html_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HISTORY_ROLLUP_TREND_HTML_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_TREND_FILE" ]; then
	alerts_stats_trend_avg=$(grep -E '^avg_alerts:' "$BUILD_SUMMARY_ALERTS_STATS_TREND_FILE" | head -n 1 | awk '{print $2}')
	alerts_stats_trend_score=$(grep -E '^avg_bundle_score:' "$BUILD_SUMMARY_ALERTS_STATS_TREND_FILE" | head -n 1 | awk '{print $2}')
	alerts_stats_trend_warn=$(grep -E '^warn:' "$BUILD_SUMMARY_ALERTS_STATS_TREND_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_trend: avg_alerts=${alerts_stats_trend_avg:-0} avg_score=${alerts_stats_trend_score:-0} warn=${alerts_stats_trend_warn:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_trend: missing ($BUILD_SUMMARY_ALERTS_STATS_TREND_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_TREND_VALIDATE_FILE" ]; then
	alerts_stats_trend_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_TREND_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_trend_validate: ${alerts_stats_trend_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_trend_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_TREND_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_DELTA_FILE" ]; then
	alerts_stats_delta_alerts=$(grep -E '^alerts_delta:' "$BUILD_SUMMARY_ALERTS_STATS_DELTA_FILE" | head -n 1 | awk '{print $2}')
	alerts_stats_delta_score=$(grep -E '^score_delta:' "$BUILD_SUMMARY_ALERTS_STATS_DELTA_FILE" | head -n 1 | awk '{print $2}')
	alerts_stats_delta_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_DELTA_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_delta: ${alerts_stats_delta_result:-unknown} alerts_delta=${alerts_stats_delta_alerts:-0} score_delta=${alerts_stats_delta_score:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_delta: missing ($BUILD_SUMMARY_ALERTS_STATS_DELTA_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_DELTA_VALIDATE_FILE" ]; then
	alerts_stats_delta_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_DELTA_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_delta_validate: ${alerts_stats_delta_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_delta_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_DELTA_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_REPORT_FILE" ]; then
	alerts_stats_report_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_REPORT_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_report: ${alerts_stats_report_result:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_report: missing ($BUILD_SUMMARY_ALERTS_STATS_REPORT_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_REPORT_VALIDATE_FILE" ]; then
	alerts_stats_report_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_REPORT_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_report_validate: ${alerts_stats_report_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_report_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_REPORT_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_REPORT_JSON_VALIDATE_FILE" ]; then
	alerts_stats_report_json_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_REPORT_JSON_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_report_json_validate: ${alerts_stats_report_json_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_report_json_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_REPORT_JSON_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_REPORT_MD_VALIDATE_FILE" ]; then
	alerts_stats_report_md_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_REPORT_MD_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_report_md_validate: ${alerts_stats_report_md_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_report_md_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_REPORT_MD_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_HTML_VALIDATE_FILE" ]; then
	alerts_stats_html_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_HTML_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_html_validate: ${alerts_stats_html_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_html_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_HTML_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_STATS_EXPORT_VALIDATE_FILE" ]; then
	alerts_stats_export_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_STATS_EXPORT_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_stats_export_validate: ${alerts_stats_export_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_stats_export_validate: missing ($BUILD_SUMMARY_ALERTS_STATS_EXPORT_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_VALIDATE_FILE" ]; then
	bundle_validate=$(grep -E '^result:' "$BUILD_SUMMARY_BUNDLE_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_validate: ${bundle_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_validate: missing ($BUILD_SUMMARY_BUNDLE_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_INDEX_TREND_FILE" ]; then
	bundle_entries=$(grep -E '^entries:' "$BUILD_SUMMARY_BUNDLE_INDEX_TREND_FILE" | head -n 1 | awk '{print $2}')
	bundle_avg=$(grep -E '^avg_files:' "$BUILD_SUMMARY_BUNDLE_INDEX_TREND_FILE" | head -n 1 | awk '{print $2}')
	bundle_warn=$(grep -E '^warn:' "$BUILD_SUMMARY_BUNDLE_INDEX_TREND_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_index_trend: entries=${bundle_entries:-0} avg_files=${bundle_avg:-0} warn=${bundle_warn:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_index_trend: missing ($BUILD_SUMMARY_BUNDLE_INDEX_TREND_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_INDEX_TREND_VALIDATE_FILE" ]; then
	bundle_trend_validate=$(grep -E '^result:' "$BUILD_SUMMARY_BUNDLE_INDEX_TREND_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_index_trend_validate: ${bundle_trend_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_index_trend_validate: missing ($BUILD_SUMMARY_BUNDLE_INDEX_TREND_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_INDEX_HISTORY_VALIDATE_FILE" ]; then
	bundle_history_validate=$(grep -E '^result:' "$BUILD_SUMMARY_BUNDLE_INDEX_HISTORY_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_index_history_validate: ${bundle_history_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_index_history_validate: missing ($BUILD_SUMMARY_BUNDLE_INDEX_HISTORY_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_INDEX_DELTA_FILE" ]; then
	bundle_delta_result=$(grep -E '^result:' "$BUILD_SUMMARY_BUNDLE_INDEX_DELTA_FILE" | head -n 1 | awk '{print $2}')
	bundle_delta_files=$(grep -E '^delta_files:' "$BUILD_SUMMARY_BUNDLE_INDEX_DELTA_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_index_delta: ${bundle_delta_result:-unknown} (delta=${bundle_delta_files:-0})" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_index_delta: missing ($BUILD_SUMMARY_BUNDLE_INDEX_DELTA_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_INDEX_DELTA_VALIDATE_FILE" ]; then
	bundle_delta_validate=$(grep -E '^result:' "$BUILD_SUMMARY_BUNDLE_INDEX_DELTA_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_index_delta_validate: ${bundle_delta_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_index_delta_validate: missing ($BUILD_SUMMARY_BUNDLE_INDEX_DELTA_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_FILE" ]; then
	bundle_overview_result=$(grep -E '^result:' "$BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_FILE" | head -n 1 | awk '{print $2}')
	bundle_overview_trend=$(grep -E '^trend_result:' "$BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_FILE" | head -n 1 | awk '{print $2}')
	bundle_overview_delta=$(grep -E '^delta_result:' "$BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_index_overview: ${bundle_overview_result:-unknown} trend=${bundle_overview_trend:-unknown} delta=${bundle_overview_delta:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_index_overview: missing ($BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_VALIDATE_FILE" ]; then
	bundle_overview_validate=$(grep -E '^result:' "$BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_index_overview_validate: ${bundle_overview_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_index_overview_validate: missing ($BUILD_SUMMARY_BUNDLE_INDEX_OVERVIEW_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_INDEX_SCORE_FILE" ]; then
	bundle_score=$(grep -E '^score:' "$BUILD_SUMMARY_BUNDLE_INDEX_SCORE_FILE" | head -n 1 | awk '{print $2}')
	bundle_score_warn=$(grep -E '^warn:' "$BUILD_SUMMARY_BUNDLE_INDEX_SCORE_FILE" | head -n 1 | awk '{print $2}')
	bundle_score_result=$(grep -E '^result:' "$BUILD_SUMMARY_BUNDLE_INDEX_SCORE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_index_score: ${bundle_score_result:-unknown} score=${bundle_score:-0} warn=${bundle_score_warn:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_index_score: missing ($BUILD_SUMMARY_BUNDLE_INDEX_SCORE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_BUNDLE_INDEX_SCORE_VALIDATE_FILE" ]; then
	bundle_score_validate=$(grep -E '^result:' "$BUILD_SUMMARY_BUNDLE_INDEX_SCORE_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_bundle_index_score_validate: ${bundle_score_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_bundle_index_score_validate: missing ($BUILD_SUMMARY_BUNDLE_INDEX_SCORE_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_FILE" ]; then
	alerts_total=$(grep -E '^total_items:' "$BUILD_SUMMARY_ALERTS_ITEMS_FILE" | head -n 1 | awk '{print $2}')
	alerts_unique=$(grep -E '^unique_items:' "$BUILD_SUMMARY_ALERTS_ITEMS_FILE" | head -n 1 | awk '{print $2}')
	alerts_mode=$(grep -E '^items_mode:' "$BUILD_SUMMARY_ALERTS_ITEMS_FILE" | head -n 1 | awk '{print $2}')
	alerts_top=$(grep -E '^top_items:' -A1 "$BUILD_SUMMARY_ALERTS_ITEMS_FILE" | tail -n 1 | sed 's/^- //')
	echo "- build_summary_alerts_items: total=${alerts_total:-0} unique=${alerts_unique:-0} mode=${alerts_mode:-unknown}" >>"$OUT_TXT"
	[ -n "$alerts_top" ] && echo "- build_summary_alerts_items_top: ${alerts_top}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items: missing ($BUILD_SUMMARY_ALERTS_ITEMS_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_VALIDATE_FILE" ]; then
	alerts_items_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_validate: ${alerts_items_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_validate: missing ($BUILD_SUMMARY_ALERTS_ITEMS_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_HISTORY_VALIDATE_FILE" ]; then
	alerts_items_history_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_HISTORY_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_history_validate: ${alerts_items_history_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_history_validate: missing ($BUILD_SUMMARY_ALERTS_ITEMS_HISTORY_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_TREND_FILE" ]; then
	alerts_avg_total=$(grep -E '^avg_total_items:' "$BUILD_SUMMARY_ALERTS_ITEMS_TREND_FILE" | head -n 1 | awk '{print $2}')
	alerts_avg_unique=$(grep -E '^avg_unique_items:' "$BUILD_SUMMARY_ALERTS_ITEMS_TREND_FILE" | head -n 1 | awk '{print $2}')
	alerts_trend_warn=$(grep -E '^warn:' "$BUILD_SUMMARY_ALERTS_ITEMS_TREND_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_trend: avg_total=${alerts_avg_total:-0} avg_unique=${alerts_avg_unique:-0} warn=${alerts_trend_warn:-0}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_trend: missing ($BUILD_SUMMARY_ALERTS_ITEMS_TREND_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_TREND_VALIDATE_FILE" ]; then
	alerts_trend_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_TREND_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_trend_validate: ${alerts_trend_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_trend_validate: missing ($BUILD_SUMMARY_ALERTS_ITEMS_TREND_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_DELTA_FILE" ]; then
	alerts_delta_total=$(grep -E '^delta_total_items:' "$BUILD_SUMMARY_ALERTS_ITEMS_DELTA_FILE" | head -n 1 | awk '{print $2}')
	alerts_delta_unique=$(grep -E '^delta_unique_items:' "$BUILD_SUMMARY_ALERTS_ITEMS_DELTA_FILE" | head -n 1 | awk '{print $2}')
	alerts_delta_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_DELTA_FILE" | head -n 1 | awk '{print $2}')
	alerts_delta_top_changed=$(grep -E '^top_text_changed:' "$BUILD_SUMMARY_ALERTS_ITEMS_DELTA_FILE" | head -n 1 | awk '{print $2}')
	alerts_delta_mode_changed=$(grep -E '^items_mode_changed:' "$BUILD_SUMMARY_ALERTS_ITEMS_DELTA_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_delta: ${alerts_delta_result:-unknown} total=${alerts_delta_total:-0} unique=${alerts_delta_unique:-0}" >>"$OUT_TXT"
	[ "$alerts_delta_top_changed" = "true" ] && echo "- build_summary_alerts_items_delta_top_changed: true" >>"$OUT_TXT"
	[ "$alerts_delta_mode_changed" = "true" ] && echo "- build_summary_alerts_items_delta_mode_changed: true" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_delta: missing ($BUILD_SUMMARY_ALERTS_ITEMS_DELTA_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_DELTA_VALIDATE_FILE" ]; then
	alerts_delta_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_DELTA_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_delta_validate: ${alerts_delta_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_delta_validate: missing ($BUILD_SUMMARY_ALERTS_ITEMS_DELTA_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_REPORT_FILE" ]; then
	items_report_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_REPORT_FILE" | head -n 1 | awk '{print $2}')
	items_report_mode=$(grep -E '^items_mode:' "$BUILD_SUMMARY_ALERTS_ITEMS_REPORT_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_report: ${items_report_result:-unknown} mode=${items_report_mode:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_report: missing ($BUILD_SUMMARY_ALERTS_ITEMS_REPORT_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_REPORT_VALIDATE_FILE" ]; then
	items_report_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_REPORT_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_report_validate: ${items_report_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_report_validate: missing ($BUILD_SUMMARY_ALERTS_ITEMS_REPORT_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_REPORT_JSON_VALIDATE_FILE" ]; then
	items_report_json_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_REPORT_JSON_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_report_json_validate: ${items_report_json_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_report_json_validate: missing ($BUILD_SUMMARY_ALERTS_ITEMS_REPORT_JSON_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_REPORT_MD_VALIDATE_FILE" ]; then
	items_report_md_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_REPORT_MD_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_report_md_validate: ${items_report_md_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_report_md_validate: missing ($BUILD_SUMMARY_ALERTS_ITEMS_REPORT_MD_VALIDATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_OVERVIEW_FILE" ]; then
	items_overview_result=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_OVERVIEW_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_overview: ${items_overview_result:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_overview: missing ($BUILD_SUMMARY_ALERTS_ITEMS_OVERVIEW_FILE)" >>"$OUT_TXT"
fi
if [ -f "$BUILD_SUMMARY_ALERTS_ITEMS_OVERVIEW_VALIDATE_FILE" ]; then
	items_overview_validate=$(grep -E '^result:' "$BUILD_SUMMARY_ALERTS_ITEMS_OVERVIEW_VALIDATE_FILE" | head -n 1 | awk '{print $2}')
	echo "- build_summary_alerts_items_overview_validate: ${items_overview_validate:-unknown}" >>"$OUT_TXT"
else
	echo "- build_summary_alerts_items_overview_validate: missing ($BUILD_SUMMARY_ALERTS_ITEMS_OVERVIEW_VALIDATE_FILE)" >>"$OUT_TXT"
fi
echo "" >>"$OUT_TXT"
echo "actions:" >>"$OUT_TXT"
if [ -n "$actions" ]; then
	printf '%b' "$actions" >>"$OUT_TXT"
else
	echo "- aucun" >>"$OUT_TXT"
fi

echo "[OK] Build dashboard generated: $OUT_TXT"
