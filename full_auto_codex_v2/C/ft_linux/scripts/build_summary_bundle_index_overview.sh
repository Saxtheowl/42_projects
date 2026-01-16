#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
TREND_TXT="$REPORT_DIR/build_summary_bundle_index_trend.txt"
DELTA_TXT="$REPORT_DIR/build_summary_bundle_index_delta.txt"
OUT_TXT="$REPORT_DIR/build_summary_bundle_index_overview.txt"
OUT_JSON="$REPORT_DIR/build_summary_bundle_index_overview.json"

usage() {
	cat <<EOF
Usage: $0 [--trend <file>] [--delta <file>] [--out <file>] [--json <file>]

Agrege tendance + delta du bundle index.
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
	echo "build_summary_bundle_index_overview generated: $(date '+%Y-%m-%d %H:%M:%S')"
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

trend_entries=$(value_from_report "$TREND_TXT" "entries")
trend_avg=$(value_from_report "$TREND_TXT" "avg_files")
trend_warn=$(value_from_report "$TREND_TXT" "warn")
trend_result=$(value_from_report "$TREND_TXT" "result")

delta_files=$(value_from_report "$DELTA_TXT" "delta_files")
delta_result=$(value_from_report "$DELTA_TXT" "result")
last_generated=$(value_from_report "$DELTA_TXT" "last_generated")
prev_generated=$(value_from_report "$DELTA_TXT" "prev_generated")
last_files=$(value_from_report "$DELTA_TXT" "last_files")
prev_files=$(value_from_report "$DELTA_TXT" "prev_files")

trend_entries="${trend_entries:-0}"
trend_avg="${trend_avg:-0}"
trend_warn="${trend_warn:-0}"
trend_result="${trend_result:-unknown}"
delta_files="${delta_files:-0}"
delta_result="${delta_result:-unknown}"
last_generated="${last_generated:-unknown}"
prev_generated="${prev_generated:-unknown}"
last_files="${last_files:-0}"
prev_files="${prev_files:-0}"

{
	echo "entries: $trend_entries"
	echo "avg_files: $trend_avg"
	echo "warn: $trend_warn"
	echo "trend_result: $trend_result"
	echo "delta_files: $delta_files"
	echo "delta_result: $delta_result"
	echo "last_generated: $last_generated"
	echo "prev_generated: $prev_generated"
	echo "last_files: $last_files"
	echo "prev_files: $prev_files"
} >>"$OUT_TXT"

overall="ok"
if [ "$trend_result" != "ok" ] || [ "$delta_result" != "ok" ]; then
	overall="warn"
fi

echo "result: $overall" >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"trend\": {"
	echo "    \"entries\": $trend_entries,"
	echo "    \"avg_files\": $trend_avg,"
	echo "    \"warn\": $trend_warn,"
	echo "    \"result\": \"$trend_result\""
	echo "  },"
	echo "  \"delta\": {"
	echo "    \"delta_files\": $delta_files,"
	echo "    \"result\": \"$delta_result\","
	echo "    \"last_generated\": \"$last_generated\","
	echo "    \"previous_generated\": \"$prev_generated\","
	echo "    \"last_files\": $last_files,"
	echo "    \"previous_files\": $prev_files"
	echo "  },"
	echo "  \"result\": \"$overall\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary bundle index overview generated: $OUT_TXT"
