#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>]
EOF
	exit 1
}

if [ "$#" -gt 0 ]; then
	if [ "$1" = "--lfs" ]; then
		LFS="${2:-}"
		[ -n "$LFS" ] || usage
	else
		usage
	fi
fi

mkdir -p "$LFS/etc/rc.d/init.d" "$LFS/etc/rc.d/rcS.d" "$LFS/etc/rc.d/rc0.d" "$LFS/etc/rc.d/rc6.d"

cat >"$LFS/etc/rc.d/init.d/mountfs" <<'EOF'
#!/bin/sh
case "$1" in
	start)
		echo "[mountfs] Mounting /proc, /sys, /dev/pts"
		mount -t proc proc /proc
		mount -t sysfs sysfs /sys
		mount -t devpts devpts /dev/pts
		;;
	stop)
		echo "[mountfs] Unmounting /proc, /sys, /dev/pts"
		umount -lf /dev/pts 2>/dev/null || true
		umount -lf /sys 2>/dev/null || true
		umount -lf /proc 2>/dev/null || true
		;;
	*)
		echo "Usage: $0 {start|stop}" >&2
		exit 1
		;;
esac
EOF

cat >"$LFS/etc/rc.d/init.d/syslog" <<'EOF'
#!/bin/sh
case "$1" in
	start)
		echo "[syslog] Placeholder (install syslog daemon later)"
		;;
	stop)
		;;
	*)
		echo "Usage: $0 {start|stop}" >&2
		exit 1
		;;
esac
EOF

cat >"$LFS/etc/rc.d/init.d/network" <<'EOF'
#!/bin/sh
case "$1" in
	start)
		if command -v dhcpcd >/dev/null 2>&1; then
			echo "[network] Starting dhcpcd"
			dhcpcd
		else
			echo "[network] dhcpcd missing"
		fi
		;;
	stop)
		if command -v dhcpcd >/dev/null 2>&1; then
			echo "[network] Stopping dhcpcd"
			dhcpcd -k
		fi
		;;
	*)
		echo "Usage: $0 {start|stop}" >&2
		exit 1
		;;
esac
EOF

chmod +x "$LFS/etc/rc.d/init.d/mountfs" "$LFS/etc/rc.d/init.d/syslog" "$LFS/etc/rc.d/init.d/network"

ln -snf ../init.d/mountfs "$LFS/etc/rc.d/rcS.d/S00mountfs"
ln -snf ../init.d/syslog "$LFS/etc/rc.d/rcS.d/S10syslog"
ln -snf ../init.d/network "$LFS/etc/rc.d/rcS.d/S20network"
ln -snf ../init.d/network "$LFS/etc/rc.d/rc0.d/K80network"
ln -snf ../init.d/network "$LFS/etc/rc.d/rc6.d/K80network"

echo "[OK] Init scripts installes sous $LFS/etc/rc.d"
