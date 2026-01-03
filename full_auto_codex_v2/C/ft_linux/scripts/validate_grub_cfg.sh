#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
BOOT_DIR="${BOOT_DIR:-$LFS/boot}"
GRUB_CFG="${GRUB_CFG:-$BOOT_DIR/grub/grub.cfg}"
FSTAB="${FSTAB:-$LFS/etc/fstab}"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/grub_report.txt"

mkdir -p "$REPORT_DIR"

missing=0

log() {
	printf '%s\n' "$1" >>"$OUT"
}

if [ ! -f "$GRUB_CFG" ]; then
	echo "[ERR] grub.cfg introuvable: $GRUB_CFG" >&2
	exit 1
fi

VMLINUX_LINE=$(grep -E "^\s*linux\s+" "$GRUB_CFG" | head -n 1 || true)
INITRD_LINE=$(grep -E "^\s*initrd\s+" "$GRUB_CFG" | head -n 1 || true)
VMLINUX_PATH=""
INITRD_PATH=""
ROOT_ARG=""
if [ -n "$VMLINUX_LINE" ]; then
	VMLINUX_PATH=$(echo "$VMLINUX_LINE" | awk '{print $2}')
	ROOT_ARG=$(echo "$VMLINUX_LINE" | awk '{for (i=3;i<=NF;i++) if ($i ~ /^root=/) {print $i; exit}}')
fi
if [ -n "$INITRD_LINE" ]; then
	INITRD_PATH=$(echo "$INITRD_LINE" | awk '{print $2}')
fi

{
	log "Grub cfg: $GRUB_CFG"
	if [ -n "$VMLINUX_LINE" ]; then
		log "linux_line: $VMLINUX_LINE"
	else
		log "linux_line: missing"
		missing=$((missing + 1))
	fi
	if [ -n "$VMLINUX_PATH" ]; then
		if [ -f "$BOOT_DIR/${VMLINUX_PATH#/boot/}" ]; then
			log "kernel: OK ($VMLINUX_PATH)"
		elif [ -f "$LFS/$VMLINUX_PATH" ]; then
			log "kernel: OK ($VMLINUX_PATH)"
		else
			log "kernel: missing ($VMLINUX_PATH)"
			missing=$((missing + 1))
		fi
	else
		log "kernel: missing (no linux line)"
		missing=$((missing + 1))
	fi
	if [ -n "$ROOT_ARG" ]; then
		log "root_arg: $ROOT_ARG"
	else
		log "root_arg: missing"
		missing=$((missing + 1))
	fi
	if [ -n "$INITRD_PATH" ]; then
		if [ -f "$BOOT_DIR/${INITRD_PATH#/boot/}" ]; then
			log "initrd: OK ($INITRD_PATH)"
		elif [ -f "$LFS/$INITRD_PATH" ]; then
			log "initrd: OK ($INITRD_PATH)"
		else
			log "initrd: missing ($INITRD_PATH)"
			missing=$((missing + 1))
		fi
	else
		if ls "$BOOT_DIR"/initramfs-*-ftlinux.img >/dev/null 2>&1; then
			log "initrd: missing (initramfs present but no initrd line)"
			missing=$((missing + 1))
		else
			log "initrd: none"
		fi
	fi
	if [ -f "$FSTAB" ]; then
		FSTAB_UUID=$(awk '$2=="/" && $1 ~ /^UUID=/ {sub(/^UUID=/, "", $1); print $1; exit}' "$FSTAB")
		if [ -n "$FSTAB_UUID" ]; then
			log "fstab_root_uuid: $FSTAB_UUID"
			if [ -n "$ROOT_ARG" ] && echo "$ROOT_ARG" | grep -q "UUID=$FSTAB_UUID"; then
				log "root_uuid_match: OK"
			else
				log "root_uuid_match: mismatch"
				missing=$((missing + 1))
			fi
		else
			log "fstab_root_uuid: missing"
			missing=$((missing + 1))
		fi
	else
		log "fstab: missing ($FSTAB)"
		missing=$((missing + 1))
	fi
	log "result: $( [ "$missing" -eq 0 ] && echo OK || echo MISSING\($missing\) )"
} >"$OUT"

echo "[OK] grub report generated: $OUT"
