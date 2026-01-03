#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
BOOT_DIR="${BOOT_DIR:-$LFS/boot}"
FSTAB="${FSTAB:-$LFS/etc/fstab}"
OUT="${OUT:-$ROOT/reports/boot_checklist.txt}"

mkdir -p "$(dirname "$OUT")"

missing=0

check_file() {
	local path="$1" label="$2"
	if [ -e "$path" ]; then
		printf "[OK] %s: %s\n" "$label" "$path"
	else
		printf "[MISS] %s: %s\n" "$label" "$path"
		missing=$((missing + 1))
	fi
}

{
	echo "Boot checklist for $LFS"
	echo ""
	check_file "$FSTAB" "fstab"
	check_file "$LFS/etc/hostname" "hostname"
	check_file "$LFS/etc/hosts" "hosts"
	check_file "$LFS/etc/inittab" "inittab"
check_file "$BOOT_DIR" "boot dir"
VMLINUX=$(ls -1 "$BOOT_DIR"/vmlinuz-*-ftlinux 2>/dev/null | head -n 1 || true)
if [ -n "$VMLINUX" ]; then
	check_file "$VMLINUX" "kernel image"
else
	check_file "$BOOT_DIR/vmlinuz-*-ftlinux" "kernel image"
fi
check_file "$BOOT_DIR/grub/grub.cfg" "grub.cfg"
INITRAMFS=$(ls -1 "$BOOT_DIR"/initramfs-*-ftlinux.img 2>/dev/null | head -n 1 || true)
if [ -n "$INITRAMFS" ]; then
	check_file "$INITRAMFS" "initramfs image"
else
	check_file "$BOOT_DIR/initramfs-*-ftlinux.img" "initramfs image"
fi
	echo ""
	if [ "$missing" -eq 0 ]; then
		echo "Result: OK"
	else
		echo "Result: MISSING ($missing)"
	fi
} >"$OUT"

echo "[OK] Checklist generated: $OUT"
