#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
JSON_FILE="$REPORT_DIR/build_summary_alerts.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts_items.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_items.json"

usage() {
	cat <<EOF
Usage: $0 [--json <file>] [--out <file>] [--json-out <file>]

Liste les items d'alertes build_summary (counts + JSON).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--json) JSON_FILE="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json-out) OUT_JSON="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_items generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "json: $JSON_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$JSON_FILE" ]; then
	echo "result: missing_json" >>"$OUT_TXT"
	echo "json missing" >>"$OUT_TXT"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$JSON_FILE\","
		echo "  \"total_items\": 0,"
		echo "  \"unique_items\": 0,"
		echo "  \"items\": [],"
		echo "  \"top_items\": [],"
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	exit 0
fi

items=$(awk '
	/"items"[[:space:]]*:[[:space:]]*\[/ {in=1; next}
	in && /\]/ {in=0}
	in && /"/ {gsub(/^[[:space:]]*,?"/,""); gsub(/".*/,""); if (length($0) > 0) print}
' "$JSON_FILE")
total_items=$(printf '%s\n' "$items" | grep -c '.')
unique_items=$(printf '%s\n' "$items" | awk 'NF{seen[$0]=1} END{c=0; for (i in seen) c++; print c}')
unique_items="${unique_items:-0}"

items_mode="present"
if [ "$total_items" -eq 0 ]; then
	items_mode="empty"
fi

top_file="$REPORT_DIR/build_summary_alerts_items_top.tmp"
tmp_file="$REPORT_DIR/build_summary_alerts_items.tmp"
if [ "$total_items" -gt 0 ]; then
	printf '%s\n' "$items" | awk 'NF{counts[$0]++} END{for (i in counts) printf "%d\t%s\n", counts[i], i}' | sort -nr | head -n 5 >"$top_file"
	printf '%s\n' "$items" | awk 'NF{counts[$0]++} END{for (i in counts) printf "%d\t%s\n", counts[i], i}' | sort -nr >"$tmp_file"
else
	: >"$top_file"
	: >"$tmp_file"
fi

{
	echo "total_items: $total_items"
	echo "unique_items: $unique_items"
	echo "items_mode: $items_mode"
	echo "items:"
	while IFS=$'\t' read -r count text; do
		[ -z "$text" ] && continue
		echo "- $count | $text"
	done <"$tmp_file"
	echo "top_items:"
	while IFS=$'\t' read -r count text; do
		[ -z "$text" ] && continue
		echo "- $count | $text"
	done <"$top_file"
	echo "result: ok"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$JSON_FILE\","
	echo "  \"total_items\": $total_items,"
	echo "  \"unique_items\": $unique_items,"
	echo "  \"items_mode\": \"$items_mode\","
	echo "  \"items\": ["
	first=1
	while IFS=$'\t' read -r count text; do
		[ -z "$text" ] && continue
		safe_text=$(printf '%s' "$text" | sed "s/\"/'/g")
		if [ "$first" -eq 0 ]; then
			echo "    ,{\"count\": $count, \"text\": \"$safe_text\"}"
		else
			echo "    {\"count\": $count, \"text\": \"$safe_text\"}"
			first=0
		fi
	done <"$tmp_file"
	echo "  ],"
	echo "  \"top_items\": ["
	first=1
	while IFS=$'\t' read -r count text; do
		[ -z "$text" ] && continue
		safe_text=$(printf '%s' "$text" | sed "s/\"/'/g")
		if [ "$first" -eq 0 ]; then
			echo "    ,{\"count\": $count, \"text\": \"$safe_text\"}"
		else
			echo "    {\"count\": $count, \"text\": \"$safe_text\"}"
			first=0
		fi
	done <"$top_file"
	echo "  ],"
	echo "  \"result\": \"ok\""
	echo "}"
} >"$OUT_JSON"

rm -f "$tmp_file"
rm -f "$top_file"

echo "[OK] Build summary alerts items generated: $OUT_TXT"
