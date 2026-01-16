#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_JSON="$REPORT_DIR/build_summary_alerts.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_stats.json"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--out <file>] [--json <file>]

Genere des stats a partir de build_summary_alerts.json.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--in) IN_JSON="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_stats generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "json: $IN_JSON"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_JSON" ]; then
	echo "result: missing_json" >>"$OUT_TXT"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$IN_JSON\","
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	exit 0
fi

alerts_total=$(grep -E '"alerts"' "$IN_JSON" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,')
alerts_total="${alerts_total:-0}"

bundle_score_present=$(grep -E '"bundle_index_score"' -A3 "$IN_JSON" | grep -E '"present"' | head -n 1 | awk -F'"' '{print $4}')
bundle_score_value=$(grep -E '"bundle_index_score"' -A4 "$IN_JSON" | grep -E '"score"' | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,')
bundle_score_result=$(grep -E '"bundle_index_score"' -A4 "$IN_JSON" | grep -E '"result"' | head -n 1 | awk -F'"' '{print $4}')

bundle_score_present="${bundle_score_present:-false}"
bundle_score_value="${bundle_score_value:-0}"
bundle_score_result="${bundle_score_result:-unknown}"

items=$(awk '
	/"items"[[:space:]]*:[[:space:]]*\[/ {in=1; next}
	in {
		if ($0 ~ /\]/) exit
		gsub(/^[[:space:]]+/, "")
		gsub(/,$/, "")
		gsub(/^"|"$/, "")
		if ($0 != "") print $0
	}
' "$IN_JSON")

gate=0
checks=0
preflight=0
bundle=0
alerts_items=0
other=0

classify() {
	case "$1" in
		gate:*) gate=$((gate + 1)) ;;
		gate_trend:*) gate=$((gate + 1)) ;;
		preflight_gate_trend:*) gate=$((gate + 1)) ;;
		checks:*) checks=$((checks + 1)) ;;
		preflight:*) preflight=$((preflight + 1)) ;;
		bundle_index_delta:*) bundle=$((bundle + 1)) ;;
		bundle_index_score:*) bundle=$((bundle + 1)) ;;
		alerts_items_delta:*) alerts_items=$((alerts_items + 1)) ;;
		*) other=$((other + 1)) ;;
	esac
}

if [ -n "$items" ]; then
	while IFS= read -r line; do
		classify "$line"
	done <<<"$items"
fi

overall="ok"
if [ "$alerts_total" -gt 0 ] || [ "$bundle_score_result" != "ok" ]; then
	overall="warn"
fi

{
	echo "alerts_total: $alerts_total"
	echo "gate: $gate"
	echo "checks: $checks"
	echo "preflight: $preflight"
	echo "bundle: $bundle"
	echo "alerts_items: $alerts_items"
	echo "other: $other"
	echo "bundle_score_present: $bundle_score_present"
	echo "bundle_score: $bundle_score_value"
	echo "bundle_score_result: $bundle_score_result"
	echo "result: $overall"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$IN_JSON\","
	echo "  \"alerts_total\": $alerts_total,"
	echo "  \"categories\": {"
	echo "    \"gate\": $gate,"
	echo "    \"checks\": $checks,"
	echo "    \"preflight\": $preflight,"
	echo "    \"bundle\": $bundle,"
	echo "    \"alerts_items\": $alerts_items,"
	echo "    \"other\": $other"
	echo "  },"
	echo "  \"bundle_index_score\": {"
	echo "    \"present\": \"$bundle_score_present\","
	echo "    \"score\": $bundle_score_value,"
	echo "    \"result\": \"$bundle_score_result\""
	echo "  },"
	echo "  \"result\": \"$overall\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts stats generated: $OUT_TXT"
