#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
WORK="${WORK:-$ROOT/work}"
FSTAB_SRC=""
HOSTNAME="ftlinux"
COPY_RESOLV=0

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--hostname <name>] [--fstab <file>] [--copy-resolv]

Options:
  --lfs <dir>      Racine cible (default: $LFS)
  --hostname <n>   Hostname (default: $HOSTNAME)
  --fstab <file>   Source fstab (default: work/fstab.generated ou configs/fstab.example)
  --copy-resolv    Copie /etc/resolv.conf de l'hote si present
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
		--hostname)
			HOSTNAME="${2:-}"
			[ -n "$HOSTNAME" ] || usage
			shift 2
			;;
		--fstab)
			FSTAB_SRC="${2:-}"
			[ -n "$FSTAB_SRC" ] || usage
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

if [ -z "$FSTAB_SRC" ]; then
	if [ -f "$WORK/fstab.generated" ]; then
		FSTAB_SRC="$WORK/fstab.generated"
	else
		FSTAB_SRC="$ROOT/configs/fstab.example"
	fi
fi

if [ ! -f "$FSTAB_SRC" ]; then
	echo "[ERR] fstab source introuvable: $FSTAB_SRC" >&2
	exit 1
fi

mkdir -p "$LFS/etc" "$LFS/var/log" "$LFS/var/tmp" "$LFS/tmp" "$LFS/root"

cat >"$LFS/etc/passwd" <<'EOF'
root:x:0:0:root:/root:/bin/bash
nobody:x:65534:65534:nobody:/dev/null:/bin/false
EOF

cat >"$LFS/etc/group" <<'EOF'
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
news:x:9:
uucp:x:10:
man:x:12:
users:x:100:
nogroup:x:65534:
EOF

cat >"$LFS/etc/hosts" <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $HOSTNAME
EOF

printf '%s\n' "$HOSTNAME" >"$LFS/etc/hostname"

cat >"$LFS/etc/issue" <<'EOF'
Welcome to ft_linux.
EOF

cat >"$LFS/etc/profile" <<'EOF'
export PATH=/usr/bin:/usr/sbin:/bin:/sbin
export HISTSIZE=1000
export PAGER=less
export PS1='\u@\h:\w\$ '
EOF

cat >"$LFS/etc/shells" <<'EOF'
/bin/sh
/bin/bash
EOF

cp -f "$FSTAB_SRC" "$LFS/etc/fstab"

if [ "$COPY_RESOLV" -eq 1 ] && [ -f /etc/resolv.conf ]; then
	cp -f /etc/resolv.conf "$LFS/etc/resolv.conf"
fi

chmod 0750 "$LFS/root"
chmod 1777 "$LFS/tmp" "$LFS/var/tmp"

echo "[OK] Base system files initialises sous $LFS"
