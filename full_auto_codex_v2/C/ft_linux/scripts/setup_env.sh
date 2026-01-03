#!/usr/bin/env bash
set -euo pipefail

# Prépare l'image disque et peut exécuter loop/mkfs/mount.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${WORK:-$ROOT/work}"
IMG="${IMG:-$WORK/disk.raw}"
SIZE_MB="${SIZE_MB:-20480}"
SFDISK="${SFDISK:-$ROOT/configs/partitions.sfdisk}"
LFS="${LFS:-$ROOT/.lfs}"
LOOP_FILE="${WORK}/loop.device"
FSTAB_FILE="${WORK}/fstab.generated"

mkdir -p "$WORK"

usage() {
	cat <<EOF
Usage: $0 [print|create|partition|attach|format|mount|umount|detach|status|all]

Env:
  WORK (default: $WORK)
  IMG (default: $IMG)
  SIZE_MB (default: $SIZE_MB)
  SFDISK (default: $SFDISK)
  LFS (default: $LFS)
  FSTAB_FILE (default: $FSTAB_FILE)
EOF
	exit 1
}

require_root() {
	if [ "$(id -u)" -ne 0 ]; then
		echo "[ERR] Action requires root." >&2
		exit 1
	fi
}

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || {
		echo "[ERR] Missing command: $1" >&2
		exit 1
	}
}

create_image() {
	require_cmd qemu-img
	if [ ! -f "$IMG" ]; then
		echo "[+] Création image ${IMG} (${SIZE_MB} MiB)"
		qemu-img create -f raw "$IMG" "${SIZE_MB}M"
	else
		echo "[=] Image déjà présente : $IMG"
	fi
}

partition_image() {
	require_root
	if [ ! -f "$SFDISK" ]; then
		echo "[ERR] Fichier sfdisk manquant : $SFDISK" >&2
		exit 1
	fi
	echo "[+] Partitionnement $IMG"
	sfdisk "$IMG" <"$SFDISK"
}

attach_loop() {
	require_root
	require_cmd losetup
	local loop
	loop=$(losetup -Pf --show "$IMG")
	echo "$loop" >"$LOOP_FILE"
	lsblk "$loop"
}

format_partitions() {
	require_root
	require_cmd mkfs.vfat
	require_cmd mkswap
	require_cmd mkfs.ext4
	local loop
	loop=$(cat "$LOOP_FILE" 2>/dev/null || true)
	if [ -z "$loop" ]; then
		echo "[ERR] Loop device not found. Run attach first." >&2
		exit 1
	fi
	mkfs.vfat -F32 "${loop}p1"
	mkswap "${loop}p2"
	mkfs.ext4 "${loop}p3"
}

mount_partitions() {
	require_root
	local loop
	loop=$(cat "$LOOP_FILE" 2>/dev/null || true)
	if [ -z "$loop" ]; then
		echo "[ERR] Loop device not found. Run attach first." >&2
		exit 1
	fi
	mkdir -p "$LFS" "$LFS/boot"
	mount "${loop}p3" "$LFS"
	mount "${loop}p1" "$LFS/boot"
	swapon "${loop}p2"
}

generate_fstab() {
	require_root
	local loop
	loop=$(cat "$LOOP_FILE" 2>/dev/null || true)
	if [ -z "$loop" ]; then
		echo "[ERR] Loop device not found. Run attach first." >&2
		exit 1
	fi
	ROOT_UUID=$(blkid -s UUID -o value "${loop}p3" || true)
	BOOT_UUID=$(blkid -s UUID -o value "${loop}p1" || true)
	SWAP_UUID=$(blkid -s UUID -o value "${loop}p2" || true)
	if [ -z "$ROOT_UUID" ] || [ -z "$BOOT_UUID" ] || [ -z "$SWAP_UUID" ]; then
		echo "[ERR] Missing UUIDs. Run format first." >&2
		exit 1
	fi
	cat >"$FSTAB_FILE" <<EOF
UUID=$ROOT_UUID / ext4 defaults 1 1
UUID=$BOOT_UUID /boot vfat defaults 0 2
UUID=$SWAP_UUID none swap sw 0 0
EOF
	echo "[+] Wrote $FSTAB_FILE"
}

umount_partitions() {
	require_root
	swapoff "$LFS" 2>/dev/null || true
	umount "$LFS/boot" 2>/dev/null || true
	umount "$LFS" 2>/dev/null || true
}

detach_loop() {
	require_root
	require_cmd losetup
	local loop
	loop=$(cat "$LOOP_FILE" 2>/dev/null || true)
	if [ -z "$loop" ]; then
		echo "[ERR] Loop device file missing: $LOOP_FILE" >&2
		exit 1
	fi
	losetup -d "$loop"
	rm -f "$LOOP_FILE"
}

status() {
	echo "[i] IMG: $IMG"
	[ -f "$IMG" ] && echo "[OK] image exists" || echo "[WARN] image missing"
	[ -f "$LOOP_FILE" ] && echo "[i] loop: $(cat "$LOOP_FILE")" || echo "[i] loop: none"
	if command -v mountpoint >/dev/null 2>&1; then
		mountpoint -q "$LFS" && echo "[OK] $LFS mounted" || echo "[WARN] $LFS not mounted"
		mountpoint -q "$LFS/boot" && echo "[OK] $LFS/boot mounted" || echo "[WARN] $LFS/boot not mounted"
	fi
}

print_instructions() {
	cat <<EOF
[i] Partitionnement (root requis):
    $0 partition

[i] Mapping loop (root requis):
    $0 attach

[i] Création systèmes de fichiers (root requis):
    $0 format

[i] Montage (root requis):
    $0 mount

[i] Variables LFS à exporter :
    export LFS=$LFS
    export LFS_TGT=x86_64-lfs-linux-gnu
    export PATH=\$LFS/tools/bin:/usr/bin

[i] Génération fstab (root requis):
    $0 fstab
EOF
}

case "${1:-print}" in
	print) create_image; print_instructions ;;
	create) create_image ;;
	partition) partition_image ;;
	attach) attach_loop ;;
	format) format_partitions ;;
	mount) mount_partitions ;;
	fstab) generate_fstab ;;
	umount) umount_partitions ;;
	detach) detach_loop ;;
	status) status ;;
	all)
		create_image
		partition_image
		attach_loop
		format_partitions
		mount_partitions
		generate_fstab
		;;
	*) usage ;;
esac
