#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_JSON="$REPORT_DIR/build_check_regressions_index.json"
OUT_TXT="$REPORT_DIR/build_check_regressions_index.txt"

SUMMARY_JSON="$REPORT_DIR/build_check_regressions_summary.json"
TOP_JSON="$REPORT_DIR/build_check_regressions_top.json"
GROUPS_JSON="$REPORT_DIR/build_check_regressions_groups.json"
TREND_JSON="$REPORT_DIR/build_check_regressions_trend.json"

usage() {
	cat <<EOF
Usage: $0 [--out <file>] [--report <file>]

Index JSON des rapports regressions (liens + resume).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--out) OUT_JSON="$2"; shift 2 ;;
		--report) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_check_regressions_index generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "summary: $SUMMARY_JSON"
	echo "top: $TOP_JSON"
	echo "groups: $GROUPS_JSON"
	echo "trend: $TREND_JSON"
	echo ""
} >"$OUT_TXT"

json_value() {
	local file="$1" key="$2"
	if [ -f "$file" ]; then
		grep -E "\"$key\"" "$file" | head -n 1 | sed -E 's/.*: *//; s/[",]//g'
	fi
}

regressions=$(json_value "$SUMMARY_JSON" "regressions")
recoveries=$(json_value "$SUMMARY_JSON" "recoveries")
total_compared=$(json_value "$SUMMARY_JSON" "total_compared")
worst_group=$(json_value "$SUMMARY_JSON" "worst_group")
worst_rate=$(json_value "$SUMMARY_JSON" "worst_rate")

result="ok"
if [ ! -f "$SUMMARY_JSON" ]; then
	result="missing"
elif [ -z "$total_compared" ] || [ "$total_compared" -eq 0 ] 2>/dev/null; then
	result="partial"
elif [ -n "$regressions" ] && [ "$regressions" -gt 0 ] 2>/dev/null; then
	result="warn"
fi

echo "regressions: ${regressions:-0}" >>"$OUT_TXT"
echo "recoveries: ${recoveries:-0}" >>"$OUT_TXT"
echo "total_compared: ${total_compared:-0}" >>"$OUT_TXT"
echo "worst_group: ${worst_group:-}" >>"$OUT_TXT"
echo "worst_rate: ${worst_rate:-0}" >>"$OUT_TXT"
echo "result: $result" >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"result\": \"$result\","
	echo "  \"summary\": \"$SUMMARY_JSON\","
	echo "  \"top\": \"$TOP_JSON\","
	echo "  \"groups\": \"$GROUPS_JSON\","
	echo "  \"trend\": \"$TREND_JSON\","
	echo "  \"metrics\": {"
	echo "    \"regressions\": ${regressions:-0},"
	echo "    \"recoveries\": ${recoveries:-0},"
	echo "    \"total_compared\": ${total_compared:-0},"
	echo "    \"worst_group\": \"${worst_group}\","
	echo "    \"worst_rate\": ${worst_rate:-0}"
	echo "  }"
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build check regressions index generated: $OUT_TXT"
