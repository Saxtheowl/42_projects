#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
BINS_LIST="${BINS_LIST:-$ROOT/configs/initramfs_bins.txt}"
OUT="${OUT:-$ROOT/configs/initramfs_manifest.generated.tsv}"

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--bins <file>] [--out <file>]

Generates an initramfs manifest from a list of binaries and their shared libs.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
			shift 2
			;;
		--bins)
			BINS_LIST="${2:-}"
			[ -n "$BINS_LIST" ] || usage
			shift 2
			;;
		--out)
			OUT="${2:-}"
			[ -n "$OUT" ] || usage
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

if [ ! -d "$LFS" ]; then
	echo "[ERR] LFS introuvable: $LFS" >&2
	exit 1
fi

if [ ! -f "$BINS_LIST" ]; then
	echo "[ERR] Bins list introuvable: $BINS_LIST" >&2
	exit 1
fi

command -v ldd >/dev/null 2>&1 || { echo "[ERR] ldd manquant." >&2; exit 1; }

tmp_files="$(mktemp)"
tmp_dirs="$(mktemp)"
trap 'rm -f "$tmp_files" "$tmp_dirs"' EXIT

add_file() {
	local path="$1"
	echo "$path" >>"$tmp_files"
	dir=$(dirname "$path")
	echo "$dir" >>"$tmp_dirs"
}

while IFS= read -r bin || [ -n "$bin" ]; do
	case "$bin" in
		""|\#*) continue ;;
	esac
	if [ ! -f "$LFS/$bin" ]; then
		echo "[WARN] binary missing: $LFS/$bin" >&2
		continue
	fi
	add_file "$bin"
	ldd "$LFS/$bin" 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i ~ /^\//) print $i}' | while IFS= read -r lib; do
		if [ -f "$LFS/$lib" ]; then
			add_file "$lib"
		fi
	done
done <"$BINS_LIST"

sort -u "$tmp_files" -o "$tmp_files"
sort -u "$tmp_dirs" -o "$tmp_dirs"

{
	echo "# type|path|target"
	while IFS= read -r dir; do
		echo "dir|${dir#/}|"
	done <"$tmp_dirs"
	while IFS= read -r file; do
		echo "file|${file#/}|"
	done <"$tmp_files"
} >"$OUT"

echo "[OK] Manifest generated: $OUT"
