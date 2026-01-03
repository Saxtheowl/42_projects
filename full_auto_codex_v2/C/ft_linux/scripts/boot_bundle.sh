#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
KERNEL_CONFIG=""
ROOTDEV=""
SKIP_KERNEL=0
SKIP_INITRAMFS=0
SKIP_GRUB=0

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--config <file>] [--rootdev <dev>] [--skip-kernel] [--skip-initramfs] [--skip-grub]

Build kernel + initramfs + grub.cfg in one sequence.
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
		--config)
			KERNEL_CONFIG="${2:-}"
			[ -n "$KERNEL_CONFIG" ] || usage
			shift 2
			;;
		--rootdev)
			ROOTDEV="${2:-}"
			[ -n "$ROOTDEV" ] || usage
			shift 2
			;;
		--skip-kernel)
			SKIP_KERNEL=1
			shift
			;;
		--skip-initramfs)
			SKIP_INITRAMFS=1
			shift
			;;
		--skip-grub)
			SKIP_GRUB=1
			shift
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

if [ "$SKIP_KERNEL" -eq 0 ]; then
	if [ -n "$KERNEL_CONFIG" ]; then
		"$ROOT/scripts/build_kernel.sh" --config "$KERNEL_CONFIG"
	else
		"$ROOT/scripts/build_kernel.sh"
	fi
fi

if [ "$SKIP_INITRAMFS" -eq 0 ]; then
	"$ROOT/scripts/build_initramfs.sh" --lfs "$LFS"
fi

if [ "$SKIP_GRUB" -eq 0 ]; then
	if [ -n "$ROOTDEV" ]; then
		"$ROOT/scripts/ensure_grub_cfg.sh" --lfs "$LFS" --rootdev "$ROOTDEV"
	else
		"$ROOT/scripts/ensure_grub_cfg.sh" --lfs "$LFS"
	fi
	"$ROOT/scripts/boot_artifacts.sh" verify --lfs "$LFS" || true
fi

echo "[OK] Boot bundle done."
