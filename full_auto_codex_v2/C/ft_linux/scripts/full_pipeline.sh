#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
ROOTDEV=""
KERNEL_CONFIG=""

SKIP_PREFLIGHT=0
SKIP_BOOTSTRAP=0
SKIP_MINI_SYSTEM=0
SKIP_SYSTEM=0
SKIP_KERNEL_CONFIG=0
SKIP_KERNEL=0
SKIP_INITRAMFS=0
SKIP_GRUB=0
SKIP_REPORTS=0

usage() {
	cat <<EOF
Usage: $0 [options]

Options:
  --lfs <dir>           LFS root (default: $LFS)
  --rootdev <dev>       Root device for grub.cfg (if UUID missing)
  --config <file>       Kernel config path
  --skip-preflight
  --skip-bootstrap
  --skip-mini-system
  --skip-system
  --skip-kernel-config
  --skip-kernel
  --skip-initramfs
  --skip-grub
  --skip-reports
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
		--rootdev)
			ROOTDEV="${2:-}"
			[ -n "$ROOTDEV" ] || usage
			shift 2
			;;
		--config)
			KERNEL_CONFIG="${2:-}"
			[ -n "$KERNEL_CONFIG" ] || usage
			shift 2
			;;
		--skip-preflight) SKIP_PREFLIGHT=1; shift ;;
		--skip-bootstrap) SKIP_BOOTSTRAP=1; shift ;;
		--skip-mini-system) SKIP_MINI_SYSTEM=1; shift ;;
		--skip-system) SKIP_SYSTEM=1; shift ;;
		--skip-kernel-config) SKIP_KERNEL_CONFIG=1; shift ;;
		--skip-kernel) SKIP_KERNEL=1; shift ;;
		--skip-initramfs) SKIP_INITRAMFS=1; shift ;;
		--skip-grub) SKIP_GRUB=1; shift ;;
		--skip-reports) SKIP_REPORTS=1; shift ;;
		-h|--help) usage ;;
		*) echo "[ERR] Option inconnue: $1" >&2; usage ;;
	esac
done

if [ "$SKIP_PREFLIGHT" -eq 0 ]; then
	"$ROOT/scripts/preflight.sh" || true
fi

if [ "$SKIP_BOOTSTRAP" -eq 0 ]; then
	"$ROOT/scripts/bootstrap_all.sh" --lfs "$LFS" || true
fi

if [ "$SKIP_MINI_SYSTEM" -eq 0 ]; then
	"$ROOT/scripts/build_mini_system.sh" all || true
fi

if [ "$SKIP_SYSTEM" -eq 0 ]; then
	"$ROOT/scripts/build_system.sh" all || true
fi

if [ "$SKIP_KERNEL_CONFIG" -eq 0 ]; then
	"$ROOT/scripts/build_kernel_config.sh" || true
fi

"$ROOT/scripts/validate_kernel_config.sh" || true

if [ "$SKIP_KERNEL" -eq 0 ]; then
	if [ -n "$KERNEL_CONFIG" ]; then
		"$ROOT/scripts/build_kernel.sh" --config "$KERNEL_CONFIG" || true
	else
		"$ROOT/scripts/build_kernel.sh" || true
	fi
fi

if [ "$SKIP_INITRAMFS" -eq 0 ]; then
	"$ROOT/scripts/build_initramfs.sh" --lfs "$LFS" --install-boot || true
fi

if [ "$SKIP_GRUB" -eq 0 ]; then
	if [ -n "$ROOTDEV" ]; then
		"$ROOT/scripts/ensure_grub_cfg.sh" --lfs "$LFS" --rootdev "$ROOTDEV" || true
	else
		"$ROOT/scripts/ensure_grub_cfg.sh" --lfs "$LFS" || true
	fi
	"$ROOT/scripts/boot_artifacts.sh" verify --lfs "$LFS" || true
fi

if [ "$SKIP_REPORTS" -eq 0 ]; then
	"$ROOT/scripts/run_reports.sh" --lfs "$LFS" || true
fi

echo "[OK] Full pipeline completed."
