#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>]

Creates minimal device nodes under /dev in the target root.
Requires root privileges.
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

if [ "$(id -u)" -ne 0 ]; then
	echo "[ERR] Action requires root." >&2
	exit 1
fi

mkdir -p "$LFS/dev"

create_node() {
	local path="$1" type="$2" major="$3" minor="$4" mode="$5"
	if [ ! -e "$path" ]; then
		mknod "$path" "$type" "$major" "$minor"
	fi
	chmod "$mode" "$path"
}

create_node "$LFS/dev/console" c 5 1 600
create_node "$LFS/dev/null" c 1 3 666
create_node "$LFS/dev/zero" c 1 5 666
create_node "$LFS/dev/tty" c 5 0 666
create_node "$LFS/dev/tty0" c 4 0 600
create_node "$LFS/dev/random" c 1 8 444
create_node "$LFS/dev/urandom" c 1 9 444

echo "[OK] Device nodes created under $LFS/dev"
