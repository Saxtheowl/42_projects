#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOGDIR="$ROOT/logs"
MANIFEST="$ROOT/configs/build_system_manifest.tsv"
SRC="$ROOT/sources"
OUT="$ROOT/reports/build_status.txt"
CSV_OUT="$ROOT/reports/build_status.csv"

trim() {
	printf '%s' "$1" | xargs
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

mkdir -p "$(dirname "$OUT")"

{
	echo "ft_linux build status"
	echo "generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "[toolchain logs]"
	for item in binutils gcc.stage1 gcc.libgcc glibc linux; do
		latest=$(ls -t "$LOGDIR/toolchain"/"$item"* 2>/dev/null | head -n 1 || true)
		if [ -n "$latest" ]; then
			echo "- $item: $(basename "$latest")"
		else
			echo "- $item: no logs"
		fi
	done
	echo ""
	echo "[system manifest]"
	if [ -f "$MANIFEST" ]; then
		while IFS= read -r line || [ -n "$line" ]; do
			case "$line" in
				""|\#*) continue ;;
			esac
			IFS='|' read -r raw_name raw_version raw_cfg raw_extra <<<"$line"
			name=$(trim "$raw_name")
			version=$(trim "$raw_version")
			tarball=$(find_tarball "$name-$version" || true)
			if [ -n "$tarball" ]; then
				echo "- $name-$version: tarball ok"
			else
				echo "- $name-$version: tarball missing"
			fi
		done <"$MANIFEST"
	else
		echo "- manifest missing: $MANIFEST"
	fi
	echo ""
	echo "[system logs]"
	for log in "$LOGDIR/system"/*.install.log; do
		[ -e "$log" ] || continue
		echo "- $(basename "$log")"
	done
} >"$OUT"

{
	echo "section,item,status"
	for item in binutils gcc.stage1 gcc.libgcc glibc linux; do
		latest=$(ls -t "$LOGDIR/toolchain"/"$item"* 2>/dev/null | head -n 1 || true)
		if [ -n "$latest" ]; then
			echo "toolchain,$item,log=$(basename "$latest")"
		else
			echo "toolchain,$item,log=missing"
		fi
	done
	if [ -f "$MANIFEST" ]; then
		while IFS= read -r line || [ -n "$line" ]; do
			case "$line" in
				""|\#*) continue ;;
			esac
			IFS='|' read -r raw_name raw_version raw_cfg raw_extra <<<"$line"
			name=$(trim "$raw_name")
			version=$(trim "$raw_version")
			if [ -z "$name" ] || [ -z "$version" ]; then
				continue
			fi
			tarball=$(find_tarball "$name-$version" || true)
			if [ -n "$tarball" ]; then
				echo "manifest,$name-$version,tarball=ok"
			else
				echo "manifest,$name-$version,tarball=missing"
			fi
		done <"$MANIFEST"
	else
		echo "manifest,manifest,missing"
	fi
	if [ -d "$LOGDIR/system" ]; then
		for log in "$LOGDIR/system"/*.install.log; do
			[ -e "$log" ] || continue
			echo "system,$(basename "$log"),install_log=present"
		done
	fi
} >"$CSV_OUT"

echo "Wrote $OUT"
echo "Wrote $CSV_OUT"
