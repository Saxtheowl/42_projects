#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
INITTAB_SRC="${INITTAB_SRC:-$ROOT/configs/inittab.example}"

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--inittab <file>]

Options:
  --lfs <dir>      Racine cible (default: $LFS)
  --inittab <file> Fichier inittab source (default: $INITTAB_SRC)
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
		--inittab)
			INITTAB_SRC="${2:-}"
			[ -n "$INITTAB_SRC" ] || usage
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

if [ ! -f "$INITTAB_SRC" ]; then
	echo "[ERR] inittab source introuvable: $INITTAB_SRC" >&2
	exit 1
fi

mkdir -p "$LFS/etc/rc.d/init.d" "$LFS/etc/rc.d/rcS.d" "$LFS/etc/rc.d/rc0.d" \
	"$LFS/etc/rc.d/rc1.d" "$LFS/etc/rc.d/rc2.d" "$LFS/etc/rc.d/rc3.d" \
	"$LFS/etc/rc.d/rc4.d" "$LFS/etc/rc.d/rc5.d" "$LFS/etc/rc.d/rc6.d"

cat >"$LFS/etc/rc.d/rcS" <<'EOF'
#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin

echo "[rcS] Mounting virtual filesystems"
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devpts devpts /dev/pts
mount -t tmpfs tmpfs /run
mkdir -p /run/lock

echo "[rcS] Setting hostname"
[ -f /etc/hostname ] && hostname -F /etc/hostname

echo "[rcS] Starting syslog (optional)"
EOF

cat >"$LFS/etc/rc.d/rc" <<'EOF'
#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin
RUNLEVEL="$1"

run_parts() {
	local dir="$1"
	[ -d "$dir" ] || return 0
	for s in "$dir"/S*; do
		[ -x "$s" ] || continue
		"$s" start
	done
	for k in "$dir"/K*; do
		[ -x "$k" ] || continue
		"$k" stop
	done
}

case "$RUNLEVEL" in
	0|1|2|3|4|5|6)
		run_parts "/etc/rc.d/rc${RUNLEVEL}.d"
		;;
	*)
		echo "Usage: $0 {0|1|2|3|4|5|6}" >&2
		exit 1
		;;
esac
EOF

cat >"$LFS/etc/rc.d/init.d/rc.local" <<'EOF'
#!/bin/sh
echo "[rc.local] Custom startup hooks"
EOF

chmod +x "$LFS/etc/rc.d/rcS" "$LFS/etc/rc.d/rc" "$LFS/etc/rc.d/init.d/rc.local"

cp -f "$INITTAB_SRC" "$LFS/etc/inittab"

ln -snf ../init.d/rc.local "$LFS/etc/rc.d/rc3.d/S99rc.local"

echo "[OK] Squelette SysV init installe sous $LFS/etc/rc.d"
