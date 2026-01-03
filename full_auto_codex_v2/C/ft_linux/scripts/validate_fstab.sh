#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
FSTAB="${FSTAB:-$LFS/etc/fstab}"
REPORT_DIR="$ROOT/reports"
REPORT_TXT="$REPORT_DIR/fstab_report.txt"
REPORT_CSV="$REPORT_DIR/fstab_report.csv"

mkdir -p "$REPORT_DIR"

if [ ! -f "$FSTAB" ]; then
	echo "[ERR] fstab introuvable: $FSTAB" >&2
	exit 1
fi

has_root=0
has_boot=0
has_swap=0
has_proc=0
has_sys=0
has_devpts=0
has_tmpfs_run=0
has_tmpfs_tmp=0

while IFS= read -r line || [ -n "$line" ]; do
	case "$line" in
		""|\#*) continue ;;
	esac
	set -- $line
	fs="$1"
	mp="$2"
	type="$3"
	case "$mp" in
		/) has_root=1 ;;
		/boot) has_boot=1 ;;
		none) [ "$type" = "swap" ] && has_swap=1 ;;
		/proc) [ "$type" = "proc" ] && has_proc=1 ;;
		/sys) [ "$type" = "sysfs" ] && has_sys=1 ;;
		/dev/pts) [ "$type" = "devpts" ] && has_devpts=1 ;;
		/run) [ "$type" = "tmpfs" ] && has_tmpfs_run=1 ;;
		/tmp) [ "$type" = "tmpfs" ] && has_tmpfs_tmp=1 ;;
	esac
done <"$FSTAB"

{
	echo "FSTAB report for $FSTAB"
	echo "root_entry: $has_root"
	echo "boot_entry: $has_boot"
	echo "swap_entry: $has_swap"
	echo "proc_entry: $has_proc"
	echo "sys_entry: $has_sys"
	echo "devpts_entry: $has_devpts"
	echo "tmpfs_run: $has_tmpfs_run"
	echo "tmpfs_tmp: $has_tmpfs_tmp"
} >"$REPORT_TXT"

{
	echo "check,value"
	echo "root_entry,$has_root"
	echo "boot_entry,$has_boot"
	echo "swap_entry,$has_swap"
	echo "proc_entry,$has_proc"
	echo "sys_entry,$has_sys"
	echo "devpts_entry,$has_devpts"
	echo "tmpfs_run,$has_tmpfs_run"
	echo "tmpfs_tmp,$has_tmpfs_tmp"
} >"$REPORT_CSV"

echo "[OK] fstab report generated: $REPORT_TXT"
