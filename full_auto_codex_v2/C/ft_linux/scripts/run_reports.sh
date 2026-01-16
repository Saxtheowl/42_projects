#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>]

Enchaine les rapports (rootfs/fstab/boot/grub/initramfs/services/manifests/release/summary).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
			shift 2
			;;
		-h|--help)
			usage
			;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

"$ROOT/scripts/rootfs_report.sh"
LFS="$LFS" "$ROOT/scripts/preflight.sh" || true
"$ROOT/scripts/preflight_report_json.sh" || true
"$ROOT/scripts/preflight_report_validate.sh" || true
"$ROOT/scripts/preflight_history.sh" || true
"$ROOT/scripts/preflight_trend.sh" || true
"$ROOT/scripts/build_preflight_gate.sh" || true
"$ROOT/scripts/build_preflight_gate_validate.sh" || true
"$ROOT/scripts/build_preflight_gate_history.sh" || true
"$ROOT/scripts/build_preflight_gate_trend.sh" || true
"$ROOT/scripts/check_env_prereqs.sh" || true
"$ROOT/scripts/missing_inputs_report.sh" || true
"$ROOT/scripts/validate_fstab.sh" --lfs "$LFS" || true
"$ROOT/scripts/boot_checklist.sh" --lfs "$LFS" || true
"$ROOT/scripts/validate_grub_cfg.sh" --lfs "$LFS" || true
"$ROOT/scripts/validate_initramfs.sh" --lfs "$LFS" || true
"$ROOT/scripts/validate_services.sh" --lfs "$LFS" || true
"$ROOT/scripts/validate_manifests.sh"
"$ROOT/scripts/release_report.sh"
"$ROOT/scripts/validate_kernel_config.sh" || true
"$ROOT/scripts/detect_boot_mode.sh" || true
"$ROOT/scripts/check_ready_to_boot.sh" --lfs "$LFS" || true
"$ROOT/scripts/boot_finalize.sh" --skip-grub-install --lfs "$LFS" || true
"$ROOT/scripts/image_report.sh" || true
"$ROOT/scripts/archive_reports.sh" || true
"$ROOT/scripts/validate_boot_archive.sh" || true
"$ROOT/scripts/partition_report.sh" || true
"$ROOT/scripts/validate_release_bundle.sh" || true
"$ROOT/scripts/validate_build_state.sh" || true
"$ROOT/scripts/build_state_report.sh" || true
"$ROOT/scripts/build_state_sync.sh" || true
"$ROOT/scripts/build_log_audit.sh" || true
"$ROOT/scripts/manifest_coverage.sh" || true
"$ROOT/scripts/build_plan.sh" || true
"$ROOT/scripts/validate_build_plan.sh" || true
"$ROOT/scripts/build_queue.sh" --status || true
"$ROOT/scripts/build_queue_retry_report.sh" || true
"$ROOT/scripts/build_queue_sync_states.sh" || true
"$ROOT/scripts/validate_build_queue_state.sh" || true
"$ROOT/scripts/build_times_report.sh" || true
"$ROOT/scripts/build_check_report.sh" || true
"$ROOT/scripts/build_check_status_report.sh" || true
"$ROOT/scripts/build_check_status_rollup.sh" || true
"$ROOT/scripts/build_check_trend.sh" || true
"$ROOT/scripts/build_check_prune.sh" || true
"$ROOT/scripts/build_check_stats.sh" || true
"$ROOT/scripts/build_check_regressions.sh" || true
"$ROOT/scripts/build_check_regressions_trend.sh" || true
"$ROOT/scripts/build_check_regressions_trend_json.sh" || true
"$ROOT/scripts/build_check_regressions_groups.sh" || true
"$ROOT/scripts/build_check_regressions_groups_json.sh" || true
"$ROOT/scripts/build_check_regressions_export_csv.sh" || true
"$ROOT/scripts/build_check_regressions_top.sh" || true
"$ROOT/scripts/build_check_regressions_summary.sh" || true
"$ROOT/scripts/build_check_regressions_summary_validate.sh" || true
"$ROOT/scripts/build_check_regressions_index.sh" || true
"$ROOT/scripts/build_check_regressions_report.sh" || true
"$ROOT/scripts/build_check_regressions_bundle.sh" || true
"$ROOT/scripts/build_check_regressions_bundle_validate.sh" || true
"$ROOT/scripts/build_check_regressions_report_html.sh" || true
"$ROOT/scripts/build_check_regressions_transitions.sh" || true
"$ROOT/scripts/build_check_regressions_transitions_json.sh" || true
"$ROOT/scripts/build_check_regressions_transitions_validate.sh" || true
"$ROOT/scripts/build_check_regressions_score.sh" || true
"$ROOT/scripts/build_check_regressions_score_json.sh" || true
"$ROOT/scripts/build_check_regressions_score_validate.sh" || true
"$ROOT/scripts/build_toolchain_report.sh" || true
"$ROOT/scripts/build_toolchain_report_json.sh" || true
"$ROOT/scripts/build_toolchain_report_validate.sh" || true
"$ROOT/scripts/build_toolchain_session_report.sh" || true
"$ROOT/scripts/build_toolchain_session_report_validate.sh" || true
"$ROOT/scripts/build_check_summary_json.sh" || true
"$ROOT/scripts/build_check_summary_validate.sh" || true
"$ROOT/scripts/build_check_export_csv.sh" || true
"$ROOT/scripts/build_check_coverage.sh" || true
"$ROOT/scripts/build_check_snapshot.sh" || true
"$ROOT/scripts/build_check_snapshot_list.sh" || true
"$ROOT/scripts/build_check_snapshot_prune.sh" || true
"$ROOT/scripts/build_check_snapshot_diff.sh" || true
"$ROOT/scripts/build_queue_metrics.sh" || true
"$ROOT/scripts/build_queue_failures.sh" || true
"$ROOT/scripts/build_queue_report.sh" || true
"$ROOT/scripts/build_state_snapshot.sh" || true
"$ROOT/scripts/build_state_list.sh" || true
"$ROOT/scripts/build_state_prune.sh" --dry-run || true
"$ROOT/scripts/build_plan_split.sh" || true
"$ROOT/scripts/build_dashboard.sh" || true
"$ROOT/scripts/build_plan_remaining.sh" || true
"$ROOT/scripts/build_progress_report.sh" || true
"$ROOT/scripts/build_progress_rollup.sh" || true
"$ROOT/scripts/build_progress_failures.sh" || true
"$ROOT/scripts/build_orchestrator_report.sh" || true
"$ROOT/scripts/build_orchestrator_status.sh" || true
"$ROOT/scripts/build_orchestrator_validate.sh" || true
"$ROOT/scripts/build_health_report.sh" || true
"$ROOT/scripts/build_gate.sh" || true
"$ROOT/scripts/build_gate_validate.sh" || true
"$ROOT/scripts/build_gate_history.sh" || true
"$ROOT/scripts/build_gate_trend.sh" || true
"$ROOT/scripts/build_summary_json.sh" || true
"$ROOT/scripts/build_summary_validate.sh" || true
"$ROOT/scripts/build_summary_report.sh" || true
"$ROOT/scripts/build_summary_report_validate.sh" || true
"$ROOT/scripts/build_summary_history.sh" || true
"$ROOT/scripts/build_summary_trend.sh" || true
"$ROOT/scripts/build_summary_alerts.sh" || true
"$ROOT/scripts/build_summary_alerts_json.sh" || true
"$ROOT/scripts/build_summary_alerts_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_items.sh" || true
"$ROOT/scripts/build_summary_alerts_items_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_items_history.sh" || true
"$ROOT/scripts/build_summary_alerts_items_history_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_items_trend.sh" || true
"$ROOT/scripts/build_summary_alerts_items_trend_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_items_delta.sh" || true
"$ROOT/scripts/build_summary_alerts_items_delta_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_items_report.sh" || true
"$ROOT/scripts/build_summary_alerts_items_report_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_items_report_json.sh" || true
"$ROOT/scripts/build_summary_alerts_items_report_json_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_items_report_md.sh" || true
"$ROOT/scripts/build_summary_alerts_items_report_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_items_overview.sh" || true
"$ROOT/scripts/build_summary_alerts_items_overview_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_report.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_report_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_report_md.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_report_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_report_html.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_report_html_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_table.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_table_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_table_md.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_table_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_table_html.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_table_html_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_score.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_score_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_anomalies.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_anomalies_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_anomalies_md.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_anomalies_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_anomalies_html.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_anomalies_html_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_md.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_html.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_html_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_score.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_score_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_score_md.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_score_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_score_html.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_score_html_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_bundle.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_bundle_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_overview.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_overview_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_overview_md.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_overview_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_overview_html.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_overview_html_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_history.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_history_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_history_md.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_history_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_history_html.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_history_html_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_history_csv_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_trend.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_trend_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_trend_md.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_trend_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_trend_html.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_history_rollup_trend_html_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_trend.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_trend_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_delta.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_delta_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_report.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_report_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_report_json.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_report_json_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_report_md.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_report_md_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_html.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_html_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_export.sh" || true
"$ROOT/scripts/build_summary_alerts_stats_export_validate.sh" || true
"$ROOT/scripts/build_summary_alerts_history.sh" || true
"$ROOT/scripts/build_summary_alerts_trend.sh" || true
"$ROOT/scripts/build_summary_bundle.sh" || true
"$ROOT/scripts/build_summary_bundle_validate.sh" || true
"$ROOT/scripts/build_summary_bundle_index.sh" || true
"$ROOT/scripts/build_summary_bundle_index_validate.sh" || true
"$ROOT/scripts/build_summary_bundle_index_history.sh" || true
"$ROOT/scripts/build_summary_bundle_index_history_validate.sh" || true
"$ROOT/scripts/build_summary_bundle_index_trend.sh" || true
"$ROOT/scripts/build_summary_bundle_index_trend_validate.sh" || true
"$ROOT/scripts/build_summary_bundle_index_delta.sh" || true
"$ROOT/scripts/build_summary_bundle_index_delta_validate.sh" || true
"$ROOT/scripts/build_summary_bundle_index_overview.sh" || true
"$ROOT/scripts/build_summary_bundle_index_overview_validate.sh" || true
"$ROOT/scripts/build_summary_bundle_index_score.sh" || true
"$ROOT/scripts/build_summary_bundle_index_score_validate.sh" || true
"$ROOT/scripts/build_check_report.sh" --strict || true
"$ROOT/scripts/build_check_gate.sh" || true
"$ROOT/scripts/summary_report.sh"
"$ROOT/scripts/assess_status.sh" || true

echo "[OK] Reports generated under $ROOT/reports"
