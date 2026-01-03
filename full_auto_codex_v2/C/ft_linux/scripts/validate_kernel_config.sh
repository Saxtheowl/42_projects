#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REQS="${REQS:-$ROOT/configs/kernel_requirements.txt}"
CONFIG_FILE="${CONFIG_FILE:-$ROOT/configs/linux-6.6.54.config}"
REPORT_DIR="$ROOT/reports"
REPORT_TXT="$REPORT_DIR/kernel_config_report.txt"
REPORT_CSV="$REPORT_DIR/kernel_config_report.csv"

usage() {
	cat <<EOF
Usage: $0 [--config <file>] [--reqs <file>]
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

mkdir -p "$REPORT_DIR"

missing=0
{
	echo "Kernel config report"
	echo "config: $CONFIG_FILE"
	echo "requirements: $REQS"
	echo ""
	while IFS= read -r req || [ -n "$req" ]; do
		case "$req" in
			""|\#*) continue ;;
		esac
		if grep -q "^$req$" "$CONFIG_FILE"; then
			echo "[OK] $req"
		else
			echo "[MISS] $req"
			missing=$((missing + 1))
		fi
	done <"$REQS"
	echo ""
	echo "result: $( [ "$missing" -eq 0 ] && echo OK || echo MISSING\($missing\) )"
} >"$REPORT_TXT"

{
	echo "requirement,status"
	while IFS= read -r req || [ -n "$req" ]; do
		case "$req" in
			""|\#*) continue ;;
		esac
		if grep -q "^$req$" "$CONFIG_FILE"; then
			echo "$req,ok"
		else
			echo "$req,missing"
		fi
	done <"$REQS"
} >"$REPORT_CSV"

echo "[OK] Kernel config report generated: $REPORT_TXT"
