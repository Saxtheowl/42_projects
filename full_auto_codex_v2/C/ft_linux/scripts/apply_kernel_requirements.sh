#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REQS="${REQS:-$ROOT/configs/kernel_requirements.txt}"
CONFIG_FILE="${CONFIG_FILE:-$ROOT/configs/linux-6.6.54.config}"
BACKUP=1

usage() {
	cat <<EOF
Usage: $0 [--config <file>] [--reqs <file>] [--no-backup]

Applies required kernel config options into the config file.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--config)
			CONFIG_FILE="${2:-}"
			[ -n "$CONFIG_FILE" ] || usage
			shift 2
			;;
		--reqs)
			REQS="${2:-}"
			[ -n "$REQS" ] || usage
			shift 2
			;;
		--no-backup)
			BACKUP=0
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

if [ ! -f "$REQS" ]; then
	echo "[ERR] Requirements introuvable: $REQS" >&2
	exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
	echo "[ERR] Config introuvable: $CONFIG_FILE" >&2
	exit 1
fi

if [ "$BACKUP" -eq 1 ]; then
	cp -f "$CONFIG_FILE" "$CONFIG_FILE.bak"
fi

while IFS= read -r req || [ -n "$req" ]; do
	case "$req" in
		""|\#*) continue ;;
	esac
	key="${req%%=*}"
	val="${req#*=}"
	if grep -q "^$key=" "$CONFIG_FILE"; then
		sed -i "s|^$key=.*|$key=$val|" "$CONFIG_FILE"
	else
		echo "$key=$val" >>"$CONFIG_FILE"
	fi
done <"$REQS"

echo "[OK] Requirements applied to $CONFIG_FILE"
