#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-/mnt/lfs}"
LOGDIR="$ROOT/logs/system"
SRC="$ROOT/sources"
JOBS="${JOBS:-$(nproc)}"

mkdir -p "$LOGDIR" "$SRC"

echo "[!] Squelette : prévoyez les tarballs vérifiés dans $SRC"
echo "[!] Les commandes suivantes supposent chroot dans $LFS (après toolchain)."

build_pkg() {
	local name="$1" version="$2" cfg="$3" extra_make="$4"
	cd "$SRC"
	[ -d "$name-$version" ] || tar xf "$name-$version".tar.*
	cd "$name-$version"
	./configure $cfg >"$LOGDIR/$name.config.log"
	make -j"$JOBS" >"$LOGDIR/$name.make.log"
	[ -z "$extra_make" ] || eval "$extra_make"
	make install >"$LOGDIR/$name.install.log"
}

case "${1:-}" in
	coreutils)
		build_pkg coreutils 9.5 "--prefix=/usr --host=$(uname -m)-lfs-linux-gnu --enable-no-install-program=kill,uptime" ""
		;;
	bash)
		build_pkg bash 5.2.21 "--prefix=/usr --without-bash-malloc" ""
		;;
	procps)
		build_pkg procps-ng 4.0.4 "--prefix=/usr --host=$(uname -m)-lfs-linux-gnu --disable-static --enable-kill" ""
		;;
	all)
		echo "Enchaînez manuellement les paquets dans l'ordre LFS (non automatisé ici)."
		;;
	*)
		echo "Usage: $0 {coreutils|bash|procps|all}" >&2
		exit 1
		;;
esac
