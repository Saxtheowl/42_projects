#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
ACTION="${1:-mount}"

usage() {
	cat <<EOF
Usage: $0 {mount|umount|status} [--lfs <dir>]
EOF
	exit 1
}

if [ "$#" -gt 1 ]; then
	if [ "${2:-}" = "--lfs" ]; then
		LFS="${3:-}"
	fi
fi

require_root() {
	if [ "$(id -u)" -ne 0 ]; then
		echo "[ERR] Action requires root." >&2
		exit 1
	fi
}

mount_all() {
	require_root
	mountpoint -q "$LFS" || {
		echo "[ERR] $LFS not mounted." >&2
		exit 1
	}
	mkdir -p "$LFS/dev" "$LFS/proc" "$LFS/sys" "$LFS/run"
	mount --bind /dev "$LFS/dev"
	mount --bind /dev/pts "$LFS/dev/pts"
	mount -t proc proc "$LFS/proc"
	mount -t sysfs sysfs "$LFS/sys"
	mount -t tmpfs tmpfs "$LFS/run"
}

umount_all() {
	require_root
	umount -lf "$LFS/run" 2>/dev/null || true
	umount -lf "$LFS/sys" 2>/dev/null || true
	umount -lf "$LFS/proc" 2>/dev/null || true
	umount -lf "$LFS/dev/pts" 2>/dev/null || true
	umount -lf "$LFS/dev" 2>/dev/null || true
}

status() {
	mountpoint -q "$LFS/dev" && echo "[OK] dev mounted" || echo "[WARN] dev not mounted"
	mountpoint -q "$LFS/dev/pts" && echo "[OK] dev/pts mounted" || echo "[WARN] dev/pts not mounted"
	mountpoint -q "$LFS/proc" && echo "[OK] proc mounted" || echo "[WARN] proc not mounted"
	mountpoint -q "$LFS/sys" && echo "[OK] sys mounted" || echo "[WARN] sys not mounted"
	mountpoint -q "$LFS/run" && echo "[OK] run mounted" || echo "[WARN] run not mounted"
}

case "$ACTION" in
	mount) mount_all ;;
	umount) umount_all ;;
	status) status ;;
	*) usage ;;
esac
