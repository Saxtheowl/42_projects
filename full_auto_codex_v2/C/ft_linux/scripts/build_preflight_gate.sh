#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
PREFLIGHT_TXT="$REPORT_DIR/preflight.txt"
PREFLIGHT_TREND_TXT="$REPORT_DIR/preflight_trend.txt"
OUT_TXT="$REPORT_DIR/build_preflight_gate.txt"
OUT_JSON="$REPORT_DIR/build_preflight_gate.json"
CONFIG_FILE="$ROOT/configs/check_gate.conf"

MAX_WARN_COUNT=""
MAX_TREND_WARN=""
FAIL_ON_WARN=0

usage() {
	cat <<EOF
Usage: $0 [--max-warn <n>] [--max-trend-warn <n>] [--fail-on-warn] [--preflight <file>] [--trend <file>] [--out <file>] [--json <file>]

Gate preflight: warn_count + trend warn entries.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
	--max-warn) MAX_WARN_COUNT="$2"; shift 2 ;;
	--max-trend-warn) MAX_TREND_WARN="$2"; shift 2 ;;
	--fail-on-warn) FAIL_ON_WARN=1; shift ;;
		--preflight) PREFLIGHT_TXT="$2"; shift 2 ;;
		--trend) PREFLIGHT_TREND_TXT="$2"; shift 2 ;;
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

config_value() {
	local key="$1"
	[ -f "$CONFIG_FILE" ] || return 0
	awk -F'=' -v key="$key" '
		$0 ~ "^[[:space:]]*#" {next}
		$1 == key {print $2; exit}
	' "$CONFIG_FILE"
}

{
	echo "build_preflight_gate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "preflight: $PREFLIGHT_TXT"
	echo "trend: $PREFLIGHT_TREND_TXT"
	echo "config: $CONFIG_FILE"
	echo "max_warn: ${MAX_WARN_COUNT:-}"
	echo "max_trend_warn: ${MAX_TREND_WARN:-}"
	echo "fail_on_warn: $FAIL_ON_WARN"
	echo ""
} >"$OUT_TXT"

if [ -z "$MAX_WARN_COUNT" ]; then
	MAX_WARN_COUNT="$(config_value "preflight_max_warn")"
fi
if [ -z "$MAX_TREND_WARN" ]; then
	MAX_TREND_WARN="$(config_value "preflight_max_trend_warn")"
fi
if [ "$FAIL_ON_WARN" -eq 0 ]; then
	FAIL_ON_WARN="$(config_value "preflight_fail_on_warn")"
fi

{
	echo "max_warn_resolved: ${MAX_WARN_COUNT:-}"
	echo "max_trend_warn_resolved: ${MAX_TREND_WARN:-}"
	echo "fail_on_warn_resolved: ${FAIL_ON_WARN:-0}"
	echo ""
} >>"$OUT_TXT"

missing=0
warn_count="0"
trend_warn="0"
preflight_result="missing"

if [ -f "$PREFLIGHT_TXT" ]; then
	preflight_result=$(grep -E '^result:' "$PREFLIGHT_TXT" | head -n 1 | awk '{print $2}')
	warn_count=$(grep -E '^warn_count:' "$PREFLIGHT_TXT" | head -n 1 | awk '{print $2}')
	preflight_result="${preflight_result:-unknown}"
	warn_count="${warn_count:-0}"
else
	echo "missing_preflight: $PREFLIGHT_TXT" >>"$OUT_TXT"
	missing=$((missing + 1))
fi

if [ -f "$PREFLIGHT_TREND_TXT" ]; then
	trend_warn=$(grep -E '^warn:' "$PREFLIGHT_TREND_TXT" | head -n 1 | awk '{print $2}')
	trend_warn="${trend_warn:-0}"
else
	echo "missing_trend: $PREFLIGHT_TREND_TXT" >>"$OUT_TXT"
	missing=$((missing + 1))
fi

gate_result="ok"
if [ "$missing" -gt 0 ]; then
	gate_result="warn"
fi

if [ -n "$MAX_WARN_COUNT" ] && [ "$warn_count" -gt "$MAX_WARN_COUNT" ]; then
	gate_result="warn"
	echo "warn_count_exceeds: $warn_count > $MAX_WARN_COUNT" >>"$OUT_TXT"
fi

if [ -n "$MAX_TREND_WARN" ] && [ "$trend_warn" -gt "$MAX_TREND_WARN" ]; then
	gate_result="warn"
	echo "trend_warn_exceeds: $trend_warn > $MAX_TREND_WARN" >>"$OUT_TXT"
fi

if [ "$FAIL_ON_WARN" -eq 1 ] && [ "$gate_result" = "warn" ]; then
	gate_result="fail"
fi

{
	echo "preflight_result: $preflight_result"
	echo "warn_count: $warn_count"
	echo "trend_warn: $trend_warn"
	echo "result: $gate_result"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"preflight\": {"
	echo "    \"source\": \"$PREFLIGHT_TXT\","
	echo "    \"result\": \"$preflight_result\","
	echo "    \"warn_count\": ${warn_count:-0}"
	echo "  },"
	echo "  \"trend\": {"
	echo "    \"source\": \"$PREFLIGHT_TREND_TXT\","
	echo "    \"warn\": ${trend_warn:-0}"
	echo "  },"
	echo "  \"limits\": {"
	echo "    \"max_warn\": \"${MAX_WARN_COUNT}\","
	echo "    \"max_trend_warn\": \"${MAX_TREND_WARN}\","
	echo "    \"fail_on_warn\": $FAIL_ON_WARN"
	echo "  },"
	echo "  \"result\": \"$gate_result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Preflight gate generated: $OUT_TXT"
