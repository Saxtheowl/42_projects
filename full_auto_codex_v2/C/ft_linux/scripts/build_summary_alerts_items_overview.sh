#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_JSON="$REPORT_DIR/build_summary_alerts_items_report.json"
TREND_JSON="$REPORT_DIR/build_summary_alerts_items_trend.json"
DELTA_JSON="$REPORT_DIR/build_summary_alerts_items_delta.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts_items_overview.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_items_overview.json"

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--trend <file>] [--delta <file>] [--out <file>] [--json <file>]

Agrege report/trend/delta des alertes items.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_JSON="$2"; shift 2 ;;
		--trend) TREND_JSON="$2"; shift 2 ;;
		--delta) DELTA_JSON="$2"; shift 2 ;;
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

value_from_json_string() {
	local file="$1" key="$2"
	if [ -f "$file" ]; then
		grep -E "\"$key\"" "$file" | head -n 1 | awk -F'"' '{print $4}'
	fi
}

value_from_json_number() {
	local file="$1" key="$2"
	if [ -f "$file" ]; then
		grep -E "\"$key\"" "$file" | head -n 1 | awk -F':' '{print $2}' | tr -d ' ,'
	fi
}

section_value_string() {
	local file="$1" section="$2" key="$3"
	awk -F'"' -v sec="\"$section\"" -v key="\"$key\"" '
		$0 ~ sec {in=1; depth=0}
		in {
			if ($0 ~ /\{/) depth++
			if ($0 ~ key) {print $4; exit}
			if ($0 ~ /\}/) {depth--; if (depth<=0) exit}
		}
	' "$file"
}

section_value_number() {
	local file="$1" section="$2" key="$3"
	awk -v sec="\"$section\"" -v key="\"$key\"" '
		$0 ~ sec {in=1; depth=0}
		in {
			if ($0 ~ /\{/) depth++
			if ($0 ~ key) {
				split($0, parts, ":")
				gsub(/[ ,]/, "", parts[2])
				print parts[2]
				exit
			}
			if ($0 ~ /\}/) {depth--; if (depth<=0) exit}
		}
	' "$file"
}

{
	echo "build_summary_alerts_items_overview generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "report: $REPORT_JSON"
	echo "trend: $TREND_JSON"
	echo "delta: $DELTA_JSON"
	echo ""
} >"$OUT_TXT"

missing=0
for file in "$REPORT_JSON" "$TREND_JSON" "$DELTA_JSON"; do
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
		echo "  \"report\": \"$REPORT_JSON\","
		echo "  \"trend\": \"$TREND_JSON\","
		echo "  \"delta\": \"$DELTA_JSON\","
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	exit 0
fi

report_items_total=$(section_value_number "$REPORT_JSON" "report" "items_total")
report_items_unique=$(section_value_number "$REPORT_JSON" "report" "items_unique")
report_items_mode=$(section_value_string "$REPORT_JSON" "report" "items_mode")
report_items_top=$(section_value_string "$REPORT_JSON" "report" "items_top")
report_result=$(section_value_string "$REPORT_JSON" "report" "result")

trend_avg_total=$(section_value_number "$TREND_JSON" "trend" "avg_total_items")
trend_avg_unique=$(section_value_number "$TREND_JSON" "trend" "avg_unique_items")
trend_warn=$(section_value_number "$TREND_JSON" "trend" "warn")
trend_result=$(section_value_string "$TREND_JSON" "trend" "result")

delta_total=$(section_value_number "$DELTA_JSON" "delta" "delta_total_items")
delta_unique=$(section_value_number "$DELTA_JSON" "delta" "delta_unique_items")
delta_top_changed=$(section_value_string "$DELTA_JSON" "delta" "top_text_changed")
delta_mode_changed=$(section_value_string "$DELTA_JSON" "delta" "items_mode_changed")
delta_result=$(section_value_string "$DELTA_JSON" "delta" "result")

if [ -z "$trend_avg_total" ]; then
	trend_avg_total=$(value_from_json_number "$TREND_JSON" "avg_total_items")
	trend_avg_unique=$(value_from_json_number "$TREND_JSON" "avg_unique_items")
	trend_warn=$(value_from_json_number "$TREND_JSON" "warn")
	trend_result=$(value_from_json_string "$TREND_JSON" "result")
fi
if [ -z "$delta_total" ]; then
	delta_total=$(value_from_json_number "$DELTA_JSON" "delta_total_items")
	delta_unique=$(value_from_json_number "$DELTA_JSON" "delta_unique_items")
	delta_top_changed=$(value_from_json_string "$DELTA_JSON" "top_text_changed")
	delta_mode_changed=$(value_from_json_string "$DELTA_JSON" "items_mode_changed")
	delta_result=$(value_from_json_string "$DELTA_JSON" "result")
fi

report_items_total="${report_items_total:-0}"
report_items_unique="${report_items_unique:-0}"
report_items_mode="${report_items_mode:-unknown}"
report_items_top="${report_items_top:-none}"
report_result="${report_result:-unknown}"
trend_avg_total="${trend_avg_total:-0}"
trend_avg_unique="${trend_avg_unique:-0}"
trend_warn="${trend_warn:-0}"
trend_result="${trend_result:-unknown}"
delta_total="${delta_total:-0}"
delta_unique="${delta_unique:-0}"
delta_top_changed="${delta_top_changed:-false}"
delta_mode_changed="${delta_mode_changed:-false}"
delta_result="${delta_result:-unknown}"

{
	echo "items_total: $report_items_total"
	echo "items_unique: $report_items_unique"
	echo "items_mode: $report_items_mode"
	echo "items_top: $report_items_top"
	echo "report_result: $report_result"
	echo "trend_avg_total: $trend_avg_total"
	echo "trend_avg_unique: $trend_avg_unique"
	echo "trend_warn: $trend_warn"
	echo "trend_result: $trend_result"
	echo "delta_total: $delta_total"
	echo "delta_unique: $delta_unique"
	echo "delta_top_changed: $delta_top_changed"
	echo "delta_mode_changed: $delta_mode_changed"
	echo "delta_result: $delta_result"
} >>"$OUT_TXT"

overall="ok"
if [ "$report_result" != "ok" ] || [ "$trend_result" != "ok" ] || [ "$delta_result" != "ok" ]; then
	overall="warn"
fi
if [ "$delta_top_changed" = "true" ] || [ "$delta_mode_changed" = "true" ]; then
	overall="warn"
fi
echo "result: $overall" >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"report\": {"
	echo "    \"items_total\": $report_items_total,"
	echo "    \"items_unique\": $report_items_unique,"
	echo "    \"items_mode\": \"$report_items_mode\","
	echo "    \"items_top\": \"$report_items_top\","
	echo "    \"result\": \"$report_result\""
	echo "  },"
	echo "  \"trend\": {"
	echo "    \"avg_total_items\": $trend_avg_total,"
	echo "    \"avg_unique_items\": $trend_avg_unique,"
	echo "    \"warn\": $trend_warn,"
	echo "    \"result\": \"$trend_result\""
	echo "  },"
	echo "  \"delta\": {"
	echo "    \"delta_total_items\": $delta_total,"
	echo "    \"delta_unique_items\": $delta_unique,"
	echo "    \"top_text_changed\": \"$delta_top_changed\","
	echo "    \"items_mode_changed\": \"$delta_mode_changed\","
	echo "    \"result\": \"$delta_result\""
	echo "  },"
	echo "  \"result\": \"$overall\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts items overview generated: $OUT_TXT"
