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
"$ROOT/scripts/check_env_prereqs.sh" || true
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
"$ROOT/scripts/build_summary_json.sh" || true
"$ROOT/scripts/build_summary_validate.sh" || true
"$ROOT/scripts/build_check_report.sh" --strict || true
"$ROOT/scripts/build_check_gate.sh" || true
"$ROOT/scripts/summary_report.sh"
"$ROOT/scripts/assess_status.sh" || true

echo "[OK] Reports generated under $ROOT/reports"
