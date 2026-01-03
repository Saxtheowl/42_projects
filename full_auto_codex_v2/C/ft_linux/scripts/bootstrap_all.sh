#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"

SKIP_ROOTFS=0
SKIP_BOOTSTRAP=0
SKIP_SYSV=0
SKIP_INIT=0
SKIP_SERVICES=0
SKIP_SYSTEM_CONFIGS=0
SKIP_DEVNODES=0

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--skip-rootfs] [--skip-bootstrap] [--skip-sysv] \\
          [--skip-init] [--skip-services] [--skip-system-configs] [--skip-devnodes]
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
		--skip-rootfs) SKIP_ROOTFS=1; shift ;;
		--skip-bootstrap) SKIP_BOOTSTRAP=1; shift ;;
		--skip-sysv) SKIP_SYSV=1; shift ;;
		--skip-init) SKIP_INIT=1; shift ;;
		--skip-services) SKIP_SERVICES=1; shift ;;
		--skip-system-configs) SKIP_SYSTEM_CONFIGS=1; shift ;;
		--skip-devnodes) SKIP_DEVNODES=1; shift ;;
		-h|--help) usage ;;
		*) echo "[ERR] Option inconnue: $1" >&2; usage ;;
	esac
done

if [ "$SKIP_ROOTFS" -eq 0 ]; then
	"$ROOT/scripts/build_rootfs.sh" --lfs "$LFS"
fi
if [ "$SKIP_BOOTSTRAP" -eq 0 ]; then
	"$ROOT/scripts/bootstrap_system.sh" --lfs "$LFS"
fi
if [ "$SKIP_SYSTEM_CONFIGS" -eq 0 ]; then
	"$ROOT/scripts/install_system_configs.sh" --lfs "$LFS"
fi
if [ "$SKIP_SYSV" -eq 0 ]; then
	"$ROOT/scripts/install_sysvinit_skeleton.sh" --lfs "$LFS"
fi
if [ "$SKIP_INIT" -eq 0 ]; then
	"$ROOT/scripts/install_init_scripts.sh" --lfs "$LFS"
fi
if [ "$SKIP_SERVICES" -eq 0 ]; then
	"$ROOT/scripts/enable_services.sh" enable --lfs "$LFS"
fi

if [ "$SKIP_DEVNODES" -eq 0 ]; then
	if [ "$(id -u)" -ne 0 ]; then
		echo "[WARN] Root required for dev nodes; skipping."
	else
		"$ROOT/scripts/create_dev_nodes.sh" --lfs "$LFS"
	fi
fi

echo "[OK] Bootstrap sequence complete."
