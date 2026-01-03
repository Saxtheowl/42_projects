#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
CMD=""

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--cmd <command>]

Monte /dev,/proc,/sys,/run via chroot_prepare.sh, entre en chroot, puis demon-te.
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
		--cmd)
			CMD="${2:-}"
			[ -n "$CMD" ] || usage
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

if [ "$(id -u)" -ne 0 ]; then
	echo "[ERR] Action requires root." >&2
	exit 1
fi

if [ ! -d "$LFS" ]; then
	echo "[ERR] LFS introuvable: $LFS" >&2
	exit 1
fi

cleanup() {
	"$ROOT/scripts/chroot_prepare.sh" umount || true
}
trap cleanup EXIT

"$ROOT/scripts/chroot_prepare.sh" mount

if [ -n "$CMD" ]; then
	chroot "$LFS" /usr/bin/env -i \
		HOME=/root TERM="$TERM" PS1='(lfs) \u:\w\$ ' \
		PATH=/usr/bin:/usr/sbin:/bin:/sbin \
		/bin/sh -c "$CMD"
else
	chroot "$LFS" /usr/bin/env -i \
		HOME=/root TERM="$TERM" PS1='(lfs) \u:\w\$ ' \
		PATH=/usr/bin:/usr/sbin:/bin:/sbin \
		/bin/bash --login
fi
