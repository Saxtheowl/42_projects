#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
TARGET="${LFS_TGT:-x86_64-lfs-linux-gnu}"
TOOLS_BIN="$LFS/tools/bin"
SRC="$ROOT/sources"
VERSION="${KERNEL_VERSION:-6.6.54}"
KERNEL_CONFIG="${KERNEL_CONFIG:-$ROOT/configs/linux-$VERSION.config}"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/missing_inputs.txt"
OUT_CSV="$REPORT_DIR/missing_inputs.csv"

mkdir -p "$REPORT_DIR"

total=0
missing=0

add_row() {
	local category="$1"
	local item="$2"
	local path="$3"
	local status="$4"
	local detail="$5"
	printf '%s | %s | %s | %s\n' "$category" "$item" "$status" "$path" >>"$OUT_TXT"
	printf '%s,%s,%s,%s,%s\n' "$category" "$item" "$status" "$path" "$detail" >>"$OUT_CSV"
	total=$((total + 1))
	if [ "$status" = "missing" ]; then
		missing=$((missing + 1))
	fi
}

check_file() {
	local category="$1"
	local item="$2"
	local path="$3"
	if [ -e "$path" ]; then
		add_row "$category" "$item" "$path" "ok" ""
	else
		add_row "$category" "$item" "$path" "missing" "expected"
	fi
}

find_tarball() {
	local base="$1"
	local ext
	for ext in tar.xz tar.gz tar.bz2 tar.zst; do
		if [ -f "$SRC/$base.$ext" ]; then
			echo "$SRC/$base.$ext"
			return 0
		fi
	done
	return 1
}

check_manifest_tarballs() {
	local manifest="$1"
	local label="$2"
	if [ ! -f "$manifest" ]; then
		add_row "manifest" "$label" "$manifest" "missing" "manifest missing"
		return
	fi
	while IFS= read -r line || [ -n "$line" ]; do
		case "$line" in
			""|\#*) continue ;;
		esac
		IFS='|' read -r raw_name raw_version _raw_cfg _raw_extra <<<"$line"
		name=$(printf '%s' "$raw_name" | xargs)
		version=$(printf '%s' "$raw_version" | xargs)
		if [ -z "$name" ] || [ -z "$version" ]; then
			continue
		fi
		if find_tarball "$name-$version" >/dev/null 2>&1; then
			add_row "tarball" "$name-$version" "$SRC" "ok" "$label"
		else
			add_row "tarball" "$name-$version" "$SRC" "missing" "$label"
		fi
	done <"$manifest"
}

{
	echo "missing inputs report"
	echo "generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
} >"$OUT_TXT"

{
	echo "category,item,status,path,detail"
} >"$OUT_CSV"

check_file "env" "lfs_root" "$LFS"
check_file "toolchain" "tools_bin" "$TOOLS_BIN"
check_file "toolchain" "$TARGET-gcc" "$TOOLS_BIN/$TARGET-gcc"
check_file "toolchain" "$TARGET-as" "$TOOLS_BIN/$TARGET-as"
check_file "toolchain" "$TARGET-ld" "$TOOLS_BIN/$TARGET-ld"
check_file "toolchain" "$TARGET-ar" "$TOOLS_BIN/$TARGET-ar"
check_file "headers" "glibc_stdio" "$LFS/usr/include/stdio.h"
check_file "headers" "linux_version" "$LFS/usr/include/linux/version.h"
check_file "toolchain" "libgcc_dir" "$LFS/tools/lib/gcc/$TARGET"

check_file "kernel" "config" "$KERNEL_CONFIG"

if ls "$LFS/boot/vmlinuz-"* >/dev/null 2>&1; then
	add_row "boot" "vmlinuz" "$LFS/boot" "ok" ""
else
	add_row "boot" "vmlinuz" "$LFS/boot" "missing" "expected vmlinuz-*"
fi

if ls "$LFS/boot/initramfs-"*-ftlinux.img >/dev/null 2>&1; then
	add_row "boot" "initramfs" "$LFS/boot" "ok" ""
else
	add_row "boot" "initramfs" "$LFS/boot" "missing" "expected initramfs-*-ftlinux.img"
fi

check_file "boot" "fstab" "$LFS/etc/fstab"
check_file "boot" "grub_cfg" "$LFS/boot/grub/grub.cfg"

check_manifest_tarballs "$ROOT/configs/build_system_manifest.tsv" "build_system_manifest"
check_manifest_tarballs "$ROOT/configs/mini_system_manifest.tsv" "mini_system_manifest"

{
	echo ""
	echo "total_checks: $total"
	echo "missing: $missing"
} >>"$OUT_TXT"

echo "[OK] missing inputs report: $OUT_TXT"
