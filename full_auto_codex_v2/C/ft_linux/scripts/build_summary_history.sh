#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
JSON_FILE="$REPORT_DIR/build_summary.json"
HISTORY_CSV="$REPORT_DIR/build_summary_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_history.txt"

usage() {
	cat <<EOF
Usage: $0 [--json <file>] [--csv <file>] [--out <file>]

Ajoute une entree dans l'historique du build_summary.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--json) JSON_FILE="$2"; shift 2 ;;
		--csv) HISTORY_CSV="$2"; shift 2 ;;
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
	echo "build_summary_history generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "json: $JSON_FILE"
	echo "csv: $HISTORY_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$JSON_FILE" ]; then
	echo "result: missing_json" >>"$OUT_TXT"
	echo "json missing" >>"$OUT_TXT"
	exit 0
fi

generated=$(grep -E '"generated"' "$JSON_FILE" | head -n 1 | awk -F'"' '{print $4}')
overall=$(grep -E '"overall"' "$JSON_FILE" | head -n 1 | awk -F'"' '{print $4}')
gate=$(grep -E '"gate"' "$JSON_FILE" | head -n 1 | awk -F'"' '{print $4}')
check_failures=$(grep -E '"failures"' "$JSON_FILE" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,')
check_missing=$(grep -E '"missing"' "$JSON_FILE" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,')

generated="${generated:-$(date '+%Y-%m-%d %H:%M:%S')}"
overall="${overall:-unknown}"
gate="${gate:-unknown}"
check_failures="${check_failures:-0}"
check_missing="${check_missing:-0}"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "generated,overall,gate,check_failures,check_missing" >"$HISTORY_CSV"
fi

echo "${generated},${overall},${gate},${check_failures},${check_missing}" >>"$HISTORY_CSV"

{
	echo "entry_generated: $generated"
	echo "entry_overall: $overall"
	echo "entry_gate: $gate"
	echo "entry_check_failures: $check_failures"
	echo "entry_check_missing: $check_missing"
	echo "result: ok"
} >>"$OUT_TXT"

echo "[OK] Build summary history updated: $HISTORY_CSV"
