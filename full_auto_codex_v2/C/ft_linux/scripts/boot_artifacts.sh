#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
BOOT_DIR="${BOOT_DIR:-$LFS/boot}"
KERNEL_VERSION="${KERNEL_VERSION:-6.6.54}"
INITRAMFS_SRC="${INITRAMFS_SRC:-$ROOT/work/initramfs.cpio.gz}"
GRUB_CFG_SRC="${GRUB_CFG_SRC:-$ROOT/configs/grub.cfg.generated}"

usage() {
	cat <<EOF
Usage: $0 {install|verify} [--lfs <dir>] [--boot <dir>] [--version <ver>] [--initramfs <file>] [--grub <file>]
EOF
	exit 1
}

ACTION="${1:-}"
shift || true

while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
			shift 2
			;;
		--boot)
			BOOT_DIR="${2:-}"
			[ -n "$BOOT_DIR" ] || usage
			shift 2
			;;
		--version)
			KERNEL_VERSION="${2:-}"
			[ -n "$KERNEL_VERSION" ] || usage
			shift 2
			;;
		--initramfs)
			INITRAMFS_SRC="${2:-}"
			[ -n "$INITRAMFS_SRC" ] || usage
			shift 2
			;;
		--grub)
			GRUB_CFG_SRC="${2:-}"
			[ -n "$GRUB_CFG_SRC" ] || usage
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

VMLINUX="$BOOT_DIR/vmlinuz-$KERNEL_VERSION-ftlinux"
INITRAMFS_DST="$BOOT_DIR/initramfs-$KERNEL_VERSION-ftlinux.img"
GRUB_DST="$BOOT_DIR/grub/grub.cfg"

install_artifacts() {
	mkdir -p "$BOOT_DIR/grub"
	if [ ! -f "$VMLINUX" ]; then
		echo "[ERR] Kernel manquant: $VMLINUX" >&2
		exit 1
	fi
	if [ -f "$INITRAMFS_SRC" ]; then
		cp -f "$INITRAMFS_SRC" "$INITRAMFS_DST"
		echo "[OK] initramfs installed: $INITRAMFS_DST"
	else
		echo "[WARN] initramfs source missing: $INITRAMFS_SRC" >&2
	fi
	if [ -f "$GRUB_CFG_SRC" ]; then
		cp -f "$GRUB_CFG_SRC" "$GRUB_DST"
		echo "[OK] grub.cfg installed: $GRUB_DST"
	else
		echo "[WARN] grub.cfg source missing: $GRUB_CFG_SRC" >&2
	fi
}

verify_artifacts() {
	local missing=0
	if [ -f "$VMLINUX" ]; then
		echo "[OK] kernel: $VMLINUX"
	else
		echo "[MISS] kernel: $VMLINUX"
		missing=$((missing + 1))
	fi
	if [ -f "$INITRAMFS_DST" ]; then
		echo "[OK] initramfs: $INITRAMFS_DST"
	else
		echo "[MISS] initramfs: $INITRAMFS_DST"
		missing=$((missing + 1))
	fi
	if [ -f "$GRUB_DST" ]; then
		echo "[OK] grub.cfg: $GRUB_DST"
	else
		echo "[MISS] grub.cfg: $GRUB_DST"
		missing=$((missing + 1))
	fi
	if [ "$missing" -ne 0 ]; then
		exit 1
	fi
}

case "$ACTION" in
	install) install_artifacts ;;
	verify) verify_artifacts ;;
	*) usage ;;
esac
