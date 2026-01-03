#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/status_assessment.txt"

mkdir -p "$REPORT_DIR"

status_line() {
	local label="$1" file="$2"
	if [ -f "$file" ]; then
		local result
		result=$(grep -E '^result:' "$file" | head -n 1 | awk '{print $2}')
		[ -n "$result" ] || result="unknown"
		printf "%-20s %s\n" "$label" "$result" >>"$OUT"
	else
		printf "%-20s missing\n" "$label" >>"$OUT"
	fi
}

{
	echo "Status assessment"
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
} >"$OUT"

status_line "ready_to_boot" "$REPORT_DIR/ready_to_boot.txt"
status_line "grub" "$REPORT_DIR/grub_report.txt"
status_line "initramfs" "$REPORT_DIR/initramfs_report.txt"
status_line "services" "$REPORT_DIR/services_report.txt"
status_line "manifests" "$REPORT_DIR/manifest_report.txt"
status_line "kernel_config" "$REPORT_DIR/kernel_config_report.txt"
status_line "boot_archive" "$REPORT_DIR/boot_archive_report.txt"
status_line "release_bundle" "$REPORT_DIR/release_bundle_report.txt"
status_line "build_state" "$REPORT_DIR/build_state_validation.txt"
status_line "build_log" "$REPORT_DIR/build_log_audit.txt"
status_line "manifest_cover" "$REPORT_DIR/manifest_coverage.txt"
status_line "build_times" "$REPORT_DIR/build_times.txt"
status_line "build_check" "$REPORT_DIR/build_check_report.txt"
status_line "build_check_status" "$REPORT_DIR/build_check_status_report.txt"
status_line "build_check_rollup" "$REPORT_DIR/build_check_status_rollup.txt"
status_line "build_check_gate" "$REPORT_DIR/build_check_gate.txt"
status_line "build_check_trend" "$REPORT_DIR/build_check_trend.txt"
status_line "build_check_prune" "$REPORT_DIR/build_check_prune.txt"
status_line "build_check_stats" "$REPORT_DIR/build_check_stats.txt"
status_line "build_check_summary" "$REPORT_DIR/build_check_summary_validate.txt"
status_line "build_check_export" "$REPORT_DIR/build_check_export.csv"
status_line "build_check_coverage" "$REPORT_DIR/build_check_coverage.txt"
status_line "build_check_snapshot" "$REPORT_DIR/build_check_snapshot.txt"
status_line "build_check_snapshot_list" "$REPORT_DIR/build_check_snapshot_list.txt"
status_line "build_check_snapshot_prune" "$REPORT_DIR/build_check_snapshot_prune.txt"
status_line "build_check_snapshot_diff" "$REPORT_DIR/build_check_snapshot_diff.txt"
status_line "build_queue" "$REPORT_DIR/build_queue_status.txt"
status_line "build_plan" "$REPORT_DIR/build_plan_validation.txt"
status_line "build_retry" "$REPORT_DIR/build_queue_retry_report.txt"
status_line "build_queue_sync" "$REPORT_DIR/build_queue_sync.txt"
status_line "build_queue_metrics" "$REPORT_DIR/build_queue_metrics.txt"
status_line "build_queue_state" "$REPORT_DIR/build_queue_state_validation.txt"
status_line "build_queue_failures" "$REPORT_DIR/build_queue_failures.txt"
status_line "build_queue_report" "$REPORT_DIR/build_queue_report.txt"
status_line "build_state_snapshot" "$REPORT_DIR/build_state_snapshot.txt"
status_line "build_state_snapshots" "$REPORT_DIR/build_state_snapshots.txt"
status_line "build_state_prune" "$REPORT_DIR/build_state_prune.txt"
status_line "build_dashboard" "$REPORT_DIR/build_dashboard.txt"
status_line "build_plan_split" "$REPORT_DIR/build_plan_splits.txt"
status_line "build_plan_remaining" "$REPORT_DIR/build_plan_remaining.txt"
status_line "build_progress" "$REPORT_DIR/build_progress.txt"
status_line "build_progress_rollup" "$REPORT_DIR/build_progress_rollup.txt"
status_line "build_progress_failures" "$REPORT_DIR/build_progress_failures.txt"
status_line "build_orchestrator" "$REPORT_DIR/build_orchestrator_report.txt"
status_line "build_orchestrator_status" "$REPORT_DIR/build_orchestrator_status.txt"
status_line "build_orchestrator_validation" "$REPORT_DIR/build_orchestrator_validation.txt"
status_line "build_health" "$REPORT_DIR/build_health_report.txt"
status_line "build_gate" "$REPORT_DIR/build_gate.txt"
status_line "build_summary_json" "$REPORT_DIR/build_summary.json"
status_line "build_summary_validate" "$REPORT_DIR/build_summary_validate.txt"

echo "" >>"$OUT"
echo "Notes:" >>"$OUT"
echo "- Run scripts/run_reports.sh to refresh all inputs." >>"$OUT"

echo "[OK] Status assessment generated: $OUT"
