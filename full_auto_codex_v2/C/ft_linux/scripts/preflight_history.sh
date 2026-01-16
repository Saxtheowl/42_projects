#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
JSON_FILE="$REPORT_DIR/preflight.json"
HISTORY_CSV="$REPORT_DIR/preflight_history.csv"
OUT_TXT="$REPORT_DIR/preflight_history.txt"

usage() {
	cat <<EOF
Usage: $0 [--json <file>] [--csv <file>] [--out <file>]

Ajoute une entree preflight dans un historique CSV.
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
	echo "preflight_history generated: $(date '+%Y-%m-%d %H:%M:%S')"
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
warn_count=$(grep -E '"warn_count"' "$JSON_FILE" | head -n 1 | awk '{print $2}' | tr -d ' ,')
result=$(grep -E '"result"' "$JSON_FILE" | head -n 1 | awk -F'"' '{print $4}')

generated="${generated:-$(date '+%Y-%m-%d %H:%M:%S')}"
warn_count="${warn_count:-0}"
result="${result:-unknown}"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "generated,warn_count,result" >"$HISTORY_CSV"
fi

echo "${generated},${warn_count},${result}" >>"$HISTORY_CSV"

{
	echo "entry_generated: $generated"
	echo "entry_warn_count: $warn_count"
	echo "entry_result: $result"
	echo "result: ok"
} >>"$OUT_TXT"

echo "[OK] Preflight history updated: $HISTORY_CSV"
