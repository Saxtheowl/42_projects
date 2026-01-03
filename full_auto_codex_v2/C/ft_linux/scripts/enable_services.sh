#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
MANIFEST="${MANIFEST:-$ROOT/configs/services_manifest.tsv}"

usage() {
	cat <<EOF
Usage: $0 {enable|disable|status} [service] [--lfs <dir>] [--manifest <file>]
EOF
	exit 1
}

ACTION="${1:-}"
SERVICE="${2:-}"

shift_count=0
if [ "$#" -ge 1 ]; then
	shift_count=1
fi
if [ "$#" -ge 2 ] && [ "$SERVICE" != "--lfs" ] && [ "$SERVICE" != "--manifest" ]; then
	shift_count=2
fi
shift "$shift_count" || true

while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
			shift 2
			;;
		--manifest)
			MANIFEST="${2:-}"
			[ -n "$MANIFEST" ] || usage
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

if [ -z "$ACTION" ]; then
	usage
fi

if [ ! -f "$MANIFEST" ]; then
	echo "[ERR] Manifest introuvable: $MANIFEST" >&2
	exit 1
fi

trim() {
	printf '%s' "$1" | xargs
}

ensure_dirs() {
	for lvl in 0 1 2 3 4 5 6 S; do
		mkdir -p "$LFS/etc/rc.d/rc${lvl}.d"
	done
}

link_service() {
	local name="$1" start_levels="$2" kill_levels="$3" sp="$4" kp="$5"
	local script="$LFS/etc/rc.d/init.d/$name"
	if [ ! -x "$script" ]; then
		echo "[WARN] Script manquant: $script"
	fi
	ensure_dirs
	local lvl
	if [ "$start_levels" = "S" ]; then
		ln -snf "../init.d/$name" "$LFS/etc/rc.d/rcS.d/S${sp}${name}"
	else
		for lvl in $(echo "$start_levels" | fold -w1); do
			ln -snf "../init.d/$name" "$LFS/etc/rc.d/rc${lvl}.d/S${sp}${name}"
		done
	fi
	if [ "$kill_levels" = "K" ]; then
		ln -snf "../init.d/$name" "$LFS/etc/rc.d/rcS.d/K${kp}${name}" 2>/dev/null || true
	else
		for lvl in $(echo "$kill_levels" | fold -w1); do
			ln -snf "../init.d/$name" "$LFS/etc/rc.d/rc${lvl}.d/K${kp}${name}"
		done
	fi
}

unlink_service() {
	local name="$1"
	find "$LFS/etc/rc.d" -type l \( -name "S*${name}" -o -name "K*${name}" \) -exec rm -f {} +
}

status_service() {
	local name="$1"
	find "$LFS/etc/rc.d" -type l \( -name "S*${name}" -o -name "K*${name}" \) -printf "%p -> %l\n" || true
}

process_manifest() {
	local line
	while IFS= read -r line || [ -n "$line" ]; do
		case "$line" in
			""|\#*) continue ;;
		esac
		IFS='|' read -r raw_name raw_start raw_kill raw_sp raw_kp <<<"$line"
		raw_name=$(trim "$raw_name")
		raw_start=$(trim "$raw_start")
		raw_kill=$(trim "$raw_kill")
		raw_sp=$(trim "$raw_sp")
		raw_kp=$(trim "$raw_kp")
		if [ -n "$SERVICE" ] && [ "$raw_name" != "$SERVICE" ]; then
			continue
		fi
		case "$ACTION" in
			enable) link_service "$raw_name" "$raw_start" "$raw_kill" "$raw_sp" "$raw_kp" ;;
			disable) unlink_service "$raw_name" ;;
			status) status_service "$raw_name" ;;
			*) usage ;;
		esac
	done <"$MANIFEST"
}

process_manifest
