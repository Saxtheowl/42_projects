#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
REPORT_DIR="$ROOT/reports"
REPORT_TXT="$REPORT_DIR/rootfs_report.txt"
REPORT_CSV="$REPORT_DIR/rootfs_report.csv"

mkdir -p "$REPORT_DIR"

if [ ! -d "$LFS" ]; then
	echo "[ERR] LFS introuvable: $LFS" >&2
	exit 1
fi

required_dirs=(bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var)
required_symlinks=(var/run var/lock etc/mtab)

missing_dirs=()
for d in "${required_dirs[@]}"; do
	if [ ! -d "$LFS/$d" ]; then
		missing_dirs+=("$d")
	fi
done

missing_links=()
for l in "${required_symlinks[@]}"; do
	if [ ! -L "$LFS/$l" ]; then
		missing_links+=("$l")
	fi
done

dir_count=$(find "$LFS" -type d 2>/dev/null | wc -l | tr -d ' ')
file_count=$(find "$LFS" -type f 2>/dev/null | wc -l | tr -d ' ')
link_count=$(find "$LFS" -type l 2>/dev/null | wc -l | tr -d ' ')

{
	echo "Rootfs report for $LFS"
	echo "Directories: $dir_count"
	echo "Files: $file_count"
	echo "Symlinks: $link_count"
	if [ "${#missing_dirs[@]}" -eq 0 ]; then
		echo "Missing dirs: none"
	else
		echo "Missing dirs: ${missing_dirs[*]}"
	fi
	if [ "${#missing_links[@]}" -eq 0 ]; then
		echo "Missing symlinks: none"
	else
		echo "Missing symlinks: ${missing_links[*]}"
	fi
} >"$REPORT_TXT"

{
	echo "metric,value"
	echo "dir_count,$dir_count"
	echo "file_count,$file_count"
	echo "link_count,$link_count"
	echo "missing_dirs,${missing_dirs[*]:-none}"
	echo "missing_symlinks,${missing_links[*]:-none}"
} >"$REPORT_CSV"

echo "[OK] Rootfs report generated: $REPORT_TXT"
