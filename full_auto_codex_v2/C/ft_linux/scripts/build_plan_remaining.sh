#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAN="$ROOT/reports/build_plan.sh"
STATE="$ROOT/work/build_queue.state"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_plan_remaining.txt"

usage() {
	cat <<EOF
Usage: $0 [--plan <file>] [--state <file>] [--out <file>]

Liste les commandes restantes du plan selon build_queue.state.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--plan) PLAN="$2"; shift 2 ;;
		--state) STATE="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_plan_remaining generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "plan: $PLAN"
	echo "state: $STATE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$PLAN" ]; then
	echo "result: missing_plan" >>"$OUT_TXT"
	echo "plan missing" >>"$OUT_TXT"
	exit 0
fi

pending_list=$(grep -v '^[[:space:]]*$' "$PLAN" | grep -v '^[[:space:]]*#' | while IFS= read -r cmd; do
	if [ -f "$STATE" ] && grep -Fxq "$cmd" "$STATE"; then
		continue
	fi
	echo "$cmd"
done)

count=0
if [ -n "$pending_list" ]; then
	count=$(printf '%s\n' "$pending_list" | wc -l | tr -d ' ')
fi

echo "pending_count: $count" >>"$OUT_TXT"
echo "pending_list:" >>"$OUT_TXT"
if [ -n "$pending_list" ]; then
	printf '%s\n' "$pending_list" >>"$OUT_TXT"
else
	echo "none" >>"$OUT_TXT"
fi

if [ "$count" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: partial" >>"$OUT_TXT"
fi

echo "[OK] Build plan remaining generated: $OUT_TXT"
