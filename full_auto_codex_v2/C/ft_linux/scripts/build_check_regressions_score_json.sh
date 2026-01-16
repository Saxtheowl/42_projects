#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/build_check_regressions_score.txt"
OUT_JSON="$REPORT_DIR/build_check_regressions_score.json"
OUT_TXT="$REPORT_DIR/build_check_regressions_score_json.txt"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--json <file>] [--out <file>]

Exporte un JSON pour le score regressions.
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
	echo "build_check_regressions_score_json generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "in: $IN_TXT"
	echo "json: $OUT_JSON"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TXT" ]; then
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$IN_TXT\","
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	echo "result: missing_report" >>"$OUT_TXT"
	echo "missing_report: $IN_TXT" >>"$OUT_TXT"
	exit 0
fi

regressions=$(grep -E '^regressions:' "$IN_TXT" | head -n 1 | awk '{print $2}')
worst_rate=$(grep -E '^worst_rate:' "$IN_TXT" | head -n 1 | awk '{print $2}')
top_transition_count=$(grep -E '^top_transition_count:' "$IN_TXT" | head -n 1 | awk '{print $2}')
score=$(grep -E '^score:' "$IN_TXT" | head -n 1 | awk '{print $2}')
result=$(grep -E '^result:' "$IN_TXT" | head -n 1 | awk '{print $2}')

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$IN_TXT\","
	echo "  \"score\": ${score:-0},"
	echo "  \"regressions\": ${regressions:-0},"
	echo "  \"worst_rate\": ${worst_rate:-0},"
	echo "  \"top_transition_count\": ${top_transition_count:-0},"
	echo "  \"result\": \"${result:-unknown}\""
	echo "}"
} >"$OUT_JSON"

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build check regressions score JSON generated: $OUT_TXT"
