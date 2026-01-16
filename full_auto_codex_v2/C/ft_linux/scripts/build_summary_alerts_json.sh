#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/build_summary_alerts.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts_json.txt"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--json <file>] [--out <file>]

Exporte un JSON a partir du rapport build_summary_alerts.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--in) IN_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
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
	echo "build_summary_alerts_json generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "in: $IN_TXT"
	echo "json: $OUT_JSON"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TXT" ]; then
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$IN_TXT\","
		echo "  \"alerts\": 0,"
		echo "  \"items\": [],"
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	echo "result: missing_report" >>"$OUT_TXT"
	echo "missing_report: $IN_TXT" >>"$OUT_TXT"
	exit 0
fi

result=$(grep -E '^result:' "$IN_TXT" | head -n 1 | awk '{print $2}')
alerts_count=$(grep -E '^- ' "$IN_TXT" | wc -l | tr -d ' ')
result="${result:-unknown}"
alerts_lines=$(grep -E '^- ' "$IN_TXT" | sed 's/^- //')
bundle_score_line=$(grep -E '^- bundle_index_score:' "$IN_TXT" | head -n 1 | sed 's/^- //')
bundle_score_present="false"
bundle_score_value="0"
bundle_score_result="unknown"
if [ -n "$bundle_score_line" ]; then
	bundle_score_present="true"
	bundle_score_value=$(printf '%s' "$bundle_score_line" | sed -n 's/.*score=\\([-0-9]*\\).*/\\1/p')
	bundle_score_result=$(printf '%s' "$bundle_score_line" | sed -n 's/.*result=\\([a-zA-Z_]*\\).*/\\1/p')
	bundle_score_value="${bundle_score_value:-0}"
	bundle_score_result="${bundle_score_result:-unknown}"
fi

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$IN_TXT\","
	echo "  \"alerts\": $alerts_count,"
	echo "  \"items\": ["
	first=1
	while IFS= read -r line; do
		[ -z "$line" ] && continue
		if [ "$first" -eq 0 ]; then
			echo "    ,\"$line\""
		else
			echo "    \"$line\""
			first=0
		fi
	done <<<"$alerts_lines"
	echo "  ],"
	echo "  \"bundle_index_score\": {"
	echo "    \"present\": \"$bundle_score_present\","
	echo "    \"score\": $bundle_score_value,"
	echo "    \"result\": \"$bundle_score_result\""
	echo "  },"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build summary alerts JSON generated: $OUT_TXT"
