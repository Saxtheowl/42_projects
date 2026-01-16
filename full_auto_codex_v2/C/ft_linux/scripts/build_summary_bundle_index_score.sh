#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
TREND_TXT="$REPORT_DIR/build_summary_bundle_index_trend.txt"
DELTA_TXT="$REPORT_DIR/build_summary_bundle_index_delta.txt"
OUT_TXT="$REPORT_DIR/build_summary_bundle_index_score.txt"
OUT_JSON="$REPORT_DIR/build_summary_bundle_index_score.json"

usage() {
	cat <<EOF
Usage: $0 [--trend <file>] [--delta <file>] [--out <file>] [--json <file>]

Calcule un score de stabilite du bundle index.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--trend) TREND_TXT="$2"; shift 2 ;;
		--delta) DELTA_TXT="$2"; shift 2 ;;
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

value_from_report() {
	local file="$1" key="$2"
	if [ -f "$file" ]; then
		grep -E "^${key}:" "$file" | head -n 1 | awk '{print $2}'
	fi
}

{
	echo "build_summary_bundle_index_score generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "trend: $TREND_TXT"
	echo "delta: $DELTA_TXT"
	echo ""
} >"$OUT_TXT"

missing=0
for file in "$TREND_TXT" "$DELTA_TXT"; do
	if [ ! -f "$file" ]; then
		echo "missing: $file" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$missing" -gt 0 ]; then
	echo "result: missing_inputs" >>"$OUT_TXT"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"trend\": \"$TREND_TXT\","
		echo "  \"delta\": \"$DELTA_TXT\","
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	exit 0
fi

warn=$(value_from_report "$TREND_TXT" "warn")
delta_files=$(value_from_report "$DELTA_TXT" "delta_files")
trend_result=$(value_from_report "$TREND_TXT" "result")
delta_result=$(value_from_report "$DELTA_TXT" "result")

warn="${warn:-0}"
delta_files="${delta_files:-0}"
trend_result="${trend_result:-unknown}"
delta_result="${delta_result:-unknown}"

delta_abs=${delta_files#-}
penalty=$((warn * 10 + delta_abs * 5))
score=$((100 - penalty))
if [ "$score" -lt 0 ]; then
	score=0
fi

result="ok"
if [ "$score" -lt 70 ] || [ "$trend_result" != "ok" ] || [ "$delta_result" != "ok" ]; then
	result="warn"
fi

{
	echo "warn: $warn"
	echo "delta_files: $delta_files"
	echo "trend_result: $trend_result"
	echo "delta_result: $delta_result"
	echo "score: $score"
	echo "result: $result"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"trend\": {"
	echo "    \"warn\": $warn,"
	echo "    \"result\": \"$trend_result\""
	echo "  },"
	echo "  \"delta\": {"
	echo "    \"delta_files\": $delta_files,"
	echo "    \"result\": \"$delta_result\""
	echo "  },"
	echo "  \"score\": $score,"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary bundle index score generated: $OUT_TXT"
