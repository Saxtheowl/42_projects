#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
BOOT_DIR="${BOOT_DIR:-$LFS/boot}"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/ready_to_boot.txt"

mkdir -p "$REPORT_DIR"

missing=0

check_path() {
	local path="$1" label="$2"
	if [ -e "$path" ]; then
		printf "[OK] %s: %s\n" "$label" "$path" >>"$OUT"
	else
		printf "[MISS] %s: %s\n" "$label" "$path" >>"$OUT"
		missing=$((missing + 1))
	fi
}

{
	echo "Ready-to-boot report"
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "lfs: $LFS"
	echo ""
} >"$OUT"

check_path "$LFS/etc/fstab" "fstab"
check_path "$LFS/etc/inittab" "inittab"
check_path "$LFS/etc/hostname" "hostname"
check_path "$BOOT_DIR/grub/grub.cfg" "grub.cfg"
check_path "$LFS/etc/rc.d/rcS" "rcS"
check_path "$LFS/etc/rc.d/rc" "rc"

VMLINUX=$(ls -1 "$BOOT_DIR"/vmlinuz-*-ftlinux 2>/dev/null | head -n 1 || true)
INITRAMFS=$(ls -1 "$BOOT_DIR"/initramfs-*-ftlinux.img 2>/dev/null | head -n 1 || true)

if [ -n "$VMLINUX" ]; then
	check_path "$VMLINUX" "kernel"
else
	check_path "$BOOT_DIR/vmlinuz-*-ftlinux" "kernel"
fi

if [ -n "$INITRAMFS" ]; then
	check_path "$INITRAMFS" "initramfs"
else
	check_path "$BOOT_DIR/initramfs-*-ftlinux.img" "initramfs"
fi

if [ -d "$LFS/etc/rc.d/rc3.d" ]; then
	echo "[OK] rc3.d present" >>"$OUT"
else
	echo "[MISS] rc3.d missing" >>"$OUT"
	missing=$((missing + 1))
fi

echo "" >>"$OUT"
if [ "$missing" -eq 0 ]; then
	echo "result: OK" >>"$OUT"
else
	echo "result: MISSING ($missing)" >>"$OUT"
fi

echo "[OK] Ready-to-boot report generated: $OUT"
