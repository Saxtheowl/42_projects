#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_health_report.txt"

REPORTS=(
	"$REPORT_DIR/preflight.txt"
	"$REPORT_DIR/preflight_validate.txt"
	"$REPORT_DIR/preflight_history.txt"
	"$REPORT_DIR/preflight_trend.txt"
	"$REPORT_DIR/build_preflight_gate.txt"
	"$REPORT_DIR/build_preflight_gate_validate.txt"
	"$REPORT_DIR/build_preflight_gate_history.txt"
	"$REPORT_DIR/build_preflight_gate_trend.txt"
	"$REPORT_DIR/status_assessment.txt"
	"$REPORT_DIR/build_dashboard.txt"
	"$REPORT_DIR/build_progress_rollup.txt"
	"$REPORT_DIR/build_queue_report.txt"
	"$REPORT_DIR/build_queue_metrics.txt"
	"$REPORT_DIR/build_check_report.txt"
	"$REPORT_DIR/build_check_status_report.txt"
	"$REPORT_DIR/build_check_status_rollup.txt"
	"$REPORT_DIR/build_check_gate.txt"
	"$REPORT_DIR/build_check_trend.txt"
	"$REPORT_DIR/build_check_prune.txt"
	"$REPORT_DIR/build_check_stats.txt"
	"$REPORT_DIR/build_check_regressions.txt"
	"$REPORT_DIR/build_check_regressions_trend.txt"
	"$REPORT_DIR/build_check_regressions_trend_json.txt"
	"$REPORT_DIR/build_check_regressions_groups.txt"
	"$REPORT_DIR/build_check_regressions_groups_json.txt"
	"$REPORT_DIR/build_check_regressions_export.txt"
	"$REPORT_DIR/build_check_regressions_top.txt"
	"$REPORT_DIR/build_check_regressions_summary.txt"
	"$REPORT_DIR/build_check_regressions_summary_validate.txt"
	"$REPORT_DIR/build_check_regressions_index.txt"
	"$REPORT_DIR/build_check_regressions_report.md"
	"$REPORT_DIR/build_check_regressions_report.html"
	"$REPORT_DIR/build_check_regressions_transitions.txt"
	"$REPORT_DIR/build_check_regressions_transitions_json.txt"
	"$REPORT_DIR/build_check_regressions_transitions_validate.txt"
	"$REPORT_DIR/build_check_regressions_score.txt"
	"$REPORT_DIR/build_check_regressions_score_json.txt"
	"$REPORT_DIR/build_check_regressions_score_validate.txt"
	"$REPORT_DIR/build_toolchain_report.txt"
	"$REPORT_DIR/build_toolchain_report_json.txt"
	"$REPORT_DIR/build_toolchain_report_validate.txt"
	"$REPORT_DIR/build_toolchain_session_report.txt"
	"$REPORT_DIR/build_toolchain_session_report_validate.txt"
	"$REPORT_DIR/build_check_regressions_bundle.txt"
	"$REPORT_DIR/build_check_regressions_bundle_validate.txt"
	"$REPORT_DIR/build_check_summary_validate.txt"
	"$REPORT_DIR/build_check_export.csv"
	"$REPORT_DIR/build_check_coverage.txt"
	"$REPORT_DIR/build_check_snapshot.txt"
	"$REPORT_DIR/build_check_snapshot_list.txt"
	"$REPORT_DIR/build_check_snapshot_prune.txt"
	"$REPORT_DIR/build_check_snapshot_diff.txt"
	"$REPORT_DIR/build_orchestrator_status.txt"
	"$REPORT_DIR/build_gate.txt"
	"$REPORT_DIR/build_gate_validate.txt"
	"$REPORT_DIR/build_gate_history.txt"
	"$REPORT_DIR/build_gate_trend.txt"
	"$REPORT_DIR/build_summary_report.txt"
	"$REPORT_DIR/build_summary_report_validate.txt"
	"$REPORT_DIR/build_summary_history.txt"
	"$REPORT_DIR/build_summary_trend.txt"
	"$REPORT_DIR/build_summary_alerts.txt"
	"$REPORT_DIR/build_summary_alerts_validate.txt"
	"$REPORT_DIR/build_summary_alerts_items.txt"
	"$REPORT_DIR/build_summary_alerts_items_validate.txt"
	"$REPORT_DIR/build_summary_alerts_items_history.txt"
	"$REPORT_DIR/build_summary_alerts_items_history_validate.txt"
	"$REPORT_DIR/build_summary_alerts_items_trend.txt"
	"$REPORT_DIR/build_summary_alerts_items_trend_validate.txt"
	"$REPORT_DIR/build_summary_alerts_items_delta.txt"
	"$REPORT_DIR/build_summary_alerts_items_delta_validate.txt"
	"$REPORT_DIR/build_summary_alerts_items_report.txt"
	"$REPORT_DIR/build_summary_alerts_items_report_validate.txt"
	"$REPORT_DIR/build_summary_alerts_items_report_json_validate.txt"
	"$REPORT_DIR/build_summary_alerts_items_report_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_items_overview.txt"
	"$REPORT_DIR/build_summary_alerts_items_overview_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats.txt"
	"$REPORT_DIR/build_summary_alerts_stats_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_report.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_report.json"
	"$REPORT_DIR/build_summary_alerts_stats_history_report_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_report.md"
	"$REPORT_DIR/build_summary_alerts_stats_history_report_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_report.html"
	"$REPORT_DIR/build_summary_alerts_stats_history_report_html_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_table.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_table.csv"
	"$REPORT_DIR/build_summary_alerts_stats_history_table_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_table.md"
	"$REPORT_DIR/build_summary_alerts_stats_history_table_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_table.html"
	"$REPORT_DIR/build_summary_alerts_stats_history_table_html_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_score.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_score_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_anomalies.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_anomalies.json"
	"$REPORT_DIR/build_summary_alerts_stats_history_anomalies_rows.csv"
	"$REPORT_DIR/build_summary_alerts_stats_history_anomalies_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_anomalies.md"
	"$REPORT_DIR/build_summary_alerts_stats_history_anomalies_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_anomalies.html"
	"$REPORT_DIR/build_summary_alerts_stats_history_anomalies_html_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup.json"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup.md"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup.html"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_html_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.json"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_score_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.md"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_score_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.html"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_score_html_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.json"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.md"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.html"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_html_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.csv"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.md"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.html"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_html_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_csv_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.json"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.md"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.html"
	"$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend_html_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_trend.txt"
	"$REPORT_DIR/build_summary_alerts_stats_trend_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_delta.txt"
	"$REPORT_DIR/build_summary_alerts_stats_delta_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_report.txt"
	"$REPORT_DIR/build_summary_alerts_stats_report_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_report_json.txt"
	"$REPORT_DIR/build_summary_alerts_stats_report_json_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_report.md"
	"$REPORT_DIR/build_summary_alerts_stats_report_md_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_report.html"
	"$REPORT_DIR/build_summary_alerts_stats_html_validate.txt"
	"$REPORT_DIR/build_summary_alerts_stats_export.txt"
	"$REPORT_DIR/build_summary_alerts_stats_export_validate.txt"
	"$REPORT_DIR/build_summary_alerts_history.txt"
	"$REPORT_DIR/build_summary_alerts_trend.txt"
	"$REPORT_DIR/build_summary_bundle_validate.txt"
	"$REPORT_DIR/build_summary_bundle_index.txt"
	"$REPORT_DIR/build_summary_bundle_index_validate.txt"
	"$REPORT_DIR/build_summary_bundle_index_history.txt"
	"$REPORT_DIR/build_summary_bundle_index_history_validate.txt"
	"$REPORT_DIR/build_summary_bundle_index_trend.txt"
	"$REPORT_DIR/build_summary_bundle_index_trend_validate.txt"
	"$REPORT_DIR/build_summary_bundle_index_delta.txt"
	"$REPORT_DIR/build_summary_bundle_index_delta_validate.txt"
	"$REPORT_DIR/build_summary_bundle_index_overview.txt"
	"$REPORT_DIR/build_summary_bundle_index_overview_validate.txt"
	"$REPORT_DIR/build_summary_bundle_index_score.txt"
	"$REPORT_DIR/build_summary_bundle_index_score_validate.txt"
)

usage() {
	cat <<EOF
Usage: $0 [--out <file>]

Synthese sante build (compte ok/warn/missing).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
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
	echo "build_health_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
} >"$OUT_TXT"

ok=0
warn=0
missing=0
unknown=0

for report in "${REPORTS[@]}"; do
	name="$(basename "$report")"
	if [ ! -f "$report" ]; then
		echo "$name: missing" >>"$OUT_TXT"
		missing=$((missing + 1))
		continue
	fi
	result=$(grep -E '^result:' "$report" | head -n 1 | awk '{print $2}')
	if [ -z "$result" ]; then
		echo "$name: unknown" >>"$OUT_TXT"
		unknown=$((unknown + 1))
	elif [ "$result" = "ok" ]; then
		echo "$name: ok" >>"$OUT_TXT"
		ok=$((ok + 1))
	elif [ "$result" = "warn" ] || [ "$result" = "partial" ] || [ "$result" = "retry_available" ]; then
		echo "$name: warn" >>"$OUT_TXT"
		warn=$((warn + 1))
	else
		echo "$name: $result" >>"$OUT_TXT"
		warn=$((warn + 1))
	fi
done

{
	echo ""
	echo "ok: $ok"
	echo "warn: $warn"
	echo "missing: $missing"
	echo "unknown: $unknown"
} >>"$OUT_TXT"

overall="ok"
if [ "$warn" -gt 0 ] || [ "$missing" -gt 0 ] || [ "$unknown" -gt 0 ]; then
	overall="warn"
fi
echo "result: $overall" >>"$OUT_TXT"

echo "[OK] Build health report generated: $OUT_TXT"
