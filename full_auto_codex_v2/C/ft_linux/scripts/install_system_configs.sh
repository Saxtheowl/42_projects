#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
CONFIG_DIR="${CONFIG_DIR:-$ROOT/configs/system}"
COPY_RESOLV=0

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--config-dir <dir>] [--copy-resolv]

Installe des configs systeme minimales (nsswitch.conf, sysctl.conf).
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
		--config-dir)
			CONFIG_DIR="${2:-}"
			[ -n "$CONFIG_DIR" ] || usage
			shift 2
			;;
		--copy-resolv)
			COPY_RESOLV=1
			shift
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

if [ ! -d "$CONFIG_DIR" ]; then
	echo "[ERR] Config dir introuvable: $CONFIG_DIR" >&2
	exit 1
fi

mkdir -p "$LFS/etc" "$LFS/etc/profile.d"

for file in nsswitch.conf sysctl.conf; do
	if [ ! -f "$CONFIG_DIR/$file" ]; then
		echo "[ERR] Fichier manquant: $CONFIG_DIR/$file" >&2
		exit 1
	fi
	cp -f "$CONFIG_DIR/$file" "$LFS/etc/$file"
done

if [ -f "$CONFIG_DIR/profile.d/locale.sh" ]; then
	cp -f "$CONFIG_DIR/profile.d/locale.sh" "$LFS/etc/profile.d/locale.sh"
fi

if [ "$COPY_RESOLV" -eq 1 ] && [ -f /etc/resolv.conf ]; then
	cp -f /etc/resolv.conf "$LFS/etc/resolv.conf"
fi

echo "[OK] System configs installed under $LFS/etc"
