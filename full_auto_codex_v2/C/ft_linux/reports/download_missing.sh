#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="${1:-./sources}"
mkdir -p "$SRC_DIR"

download() {
	local url="$1"
	local out="$SRC_DIR/$(basename "$url")"
	if [ -f "$out" ]; then
		echo "[=] already present: $out"
		return
	fi
	echo "[+] $url"
	curl -L "$url" -o "$out"
}
download 'https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz'
download 'https://ftp.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz'
download 'https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz'
download 'https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz'
download 'https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz'
download 'https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz'
download 'https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz'
download 'https://ftp.gnu.org/gnu/texinfo/texinfo-7.1.tar.xz'
download 'https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.40/util-linux-2.40.2.tar.xz'
