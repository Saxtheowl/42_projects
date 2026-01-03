#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/boot_mode.txt"

mkdir -p "$REPORT_DIR"

mode="BIOS"
if [ -d /sys/firmware/efi ]; then
	mode="UEFI"
fi

{
	echo "Boot mode detection"
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "mode: $mode"
	if [ "$mode" = "UEFI" ]; then
		echo "recommended grub target: x86_64-efi"
	else
		echo "recommended grub target: i386-pc"
	fi
} >"$OUT"

echo "[OK] Boot mode report: $OUT"
