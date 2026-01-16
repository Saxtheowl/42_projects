#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
STATE="$ROOT/work/build_queue.state"
PLAN="$ROOT/reports/build_plan.sh"
OUT_TXT="$REPORT_DIR/build_queue_state_validation.txt"
OUT_CSV="$REPORT_DIR/build_queue_state_validation.csv"
PRUNE=0

usage() {
	cat <<EOF
Usage: $0 [--state <file>] [--plan <file>] [--prune]

Valide build_queue.state contre le plan (et optionnellement purge les commandes inconnues).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--state) STATE="$2"; shift 2 ;;
		--plan) PLAN="$2"; shift 2 ;;
		--prune) PRUNE=1; shift ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR" "$(dirname "$STATE")"

{
	echo "build_queue_state_validation generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "state: $STATE"
	echo "plan: $PLAN"
	echo "prune: $PRUNE"
	echo ""
} >"$OUT_TXT"

echo "command,status" >"$OUT_CSV"

if [ ! -f "$STATE" ]; then
	echo "result: missing_state" >>"$OUT_TXT"
	echo "state missing" >>"$OUT_TXT"
	exit 0
fi

if [ ! -f "$PLAN" ]; then
	echo "result: missing_plan" >>"$OUT_TXT"
	echo "plan missing" >>"$OUT_TXT"
	exit 0
fi

plan_file="$(mktemp)"
state_file="$(mktemp)"
grep -v '^[[:space:]]*$' "$PLAN" | grep -v '^[[:space:]]*#' | sort -u >"$plan_file"
sort -u "$STATE" >"$state_file"

unknown_list=$(comm -23 "$state_file" "$plan_file" || true)
unknown_count=0
if [ -n "$unknown_list" ]; then
	unknown_count=$(printf '%s\n' "$unknown_list" | wc -l | tr -d ' ')
fi

while IFS= read -r line; do
	[ -n "$line" ] || continue
	if printf '%s\n' "$unknown_list" | grep -Fxq "$line"; then
		echo "$line,unknown" >>"$OUT_CSV"
	else
		echo "$line,ok" >>"$OUT_CSV"
	fi
done <"$state_file"

if [ "$unknown_count" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
	echo "unknown_count: $unknown_count" >>"$OUT_TXT"
	echo "unknown_list:" >>"$OUT_TXT"
	printf '%s\n' "$unknown_list" >>"$OUT_TXT"
	if [ "$PRUNE" -eq 1 ]; then
		comm -12 "$state_file" "$plan_file" >"$STATE"
		echo "pruned: yes" >>"$OUT_TXT"
	fi
fi

rm -f "$plan_file" "$state_file"

echo "[OK] Build queue state validation generated: $OUT_TXT $OUT_CSV"
