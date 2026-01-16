#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
JSON_FILE="$REPORT_DIR/build_summary_alerts_items.json"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_items_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_items_history.txt"

usage() {
	cat <<EOF
Usage: $0 [--json <file>] [--csv <file>] [--out <file>]

Ajoute une entree dans l'historique des alertes items.
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
	echo "build_summary_alerts_items_history generated: $(date '+%Y-%m-%d %H:%M:%S')"
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
total_items=$(grep -E '"total_items"' "$JSON_FILE" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,')
unique_items=$(grep -E '"unique_items"' "$JSON_FILE" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,')
items_mode=$(grep -E '"items_mode"' "$JSON_FILE" | head -n 1 | awk -F'"' '{print $4}')
result=$(grep -E '"result"' "$JSON_FILE" | head -n 1 | awk -F'"' '{print $4}')
top_text=$(awk -F'"' '
	/"top_items"[[:space:]]*:/ {in=1; next}
	in && /"text"/ {print $4; exit}
' "$JSON_FILE")

generated="${generated:-$(date '+%Y-%m-%d %H:%M:%S')}"
total_items="${total_items:-0}"
unique_items="${unique_items:-0}"
items_mode="${items_mode:-unknown}"
result="${result:-unknown}"
top_text="${top_text:-none}"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "generated,total_items,unique_items,items_mode,top_text,result" >"$HISTORY_CSV"
fi

echo "${generated},${total_items},${unique_items},${items_mode},${top_text},${result}" >>"$HISTORY_CSV"

{
	echo "entry_generated: $generated"
	echo "entry_total_items: $total_items"
	echo "entry_unique_items: $unique_items"
	echo "entry_items_mode: $items_mode"
	echo "entry_top_text: $top_text"
	echo "entry_result: $result"
	echo "result: ok"
} >>"$OUT_TXT"

echo "[OK] Build summary alerts items history updated: $HISTORY_CSV"
