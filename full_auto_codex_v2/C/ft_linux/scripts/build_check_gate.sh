#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_check_report.txt"
ROLLUP_FILE="$REPORT_DIR/build_check_status_rollup.txt"
STATS_FILE="$REPORT_DIR/build_check_stats.txt"
OUT_TXT="$REPORT_DIR/build_check_gate.txt"
OUT_JSON="$REPORT_DIR/build_check_gate.json"
CONFIG_FILE="$ROOT/configs/check_gate.conf"
FAIL_ON_WARN=0
MAX_FAIL=-1
MAX_IGNORED=-1
MAX_MISSING=-1
MAX_SEVERITY=-1

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--rollup <file>] [--stats <file>] [--out <file>] [--json <file>] [--config <file>] [--fail-on-warn] [--max-fail <n>] [--max-ignored <n>] [--max-missing <n>] [--max-severity <n>]

Gate checks (make check) a partir des rapports existants.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
		--rollup) ROLLUP_FILE="$2"; shift 2 ;;
		--stats) STATS_FILE="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		--config)
			CONFIG_FILE="$2"
			shift 2
			;;
		--fail-on-warn) FAIL_ON_WARN=1; shift ;;
		--max-fail) MAX_FAIL="$2"; shift 2 ;;
		--max-ignored) MAX_IGNORED="$2"; shift 2 ;;
		--max-missing) MAX_MISSING="$2"; shift 2 ;;
		--max-severity) MAX_SEVERITY="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

warn=0
fail=0

load_config() {
	local file="$1"
	[ -f "$file" ] || return 0
	while IFS= read -r line; do
		case "$line" in
			""|\#*) continue ;;
		esac
		key="${line%%=*}"
		val="${line#*=}"
		case "$key" in
			max_fail) [ "$MAX_FAIL" -eq -1 ] && MAX_FAIL="$val" ;;
			max_ignored) [ "$MAX_IGNORED" -eq -1 ] && MAX_IGNORED="$val" ;;
			max_missing) [ "$MAX_MISSING" -eq -1 ] && MAX_MISSING="$val" ;;
			max_severity) [ "$MAX_SEVERITY" -eq -1 ] && MAX_SEVERITY="$val" ;;
			fail_on_warn) [ "$FAIL_ON_WARN" -eq 0 ] && FAIL_ON_WARN="$val" ;;
		esac
	done <"$file"
}

load_config "$CONFIG_FILE"

json_number_or_null() {
	local value="$1"
	if [ -z "$value" ]; then
		echo "null"
	elif [ "$value" -lt 0 ]; then
		echo "null"
	else
		echo "$value"
	fi
}

write_json() {
	local result="$1"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"report\": \"$REPORT_FILE\","
		echo "  \"rollup\": \"$ROLLUP_FILE\","
		echo "  \"stats\": \"$STATS_FILE\","
		echo "  \"fail_on_warn\": $FAIL_ON_WARN,"
		echo "  \"max_fail\": $(json_number_or_null "$MAX_FAIL"),"
		echo "  \"max_ignored\": $(json_number_or_null "$MAX_IGNORED"),"
		echo "  \"max_missing\": $(json_number_or_null "$MAX_MISSING"),"
		echo "  \"max_severity\": $(json_number_or_null "$MAX_SEVERITY"),"
		echo "  \"result\": \"$result\""
		echo "}"
	} >"$OUT_JSON"
}

{
	echo "build_check_gate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "report: $REPORT_FILE"
	echo "rollup: $ROLLUP_FILE"
	echo "stats: $STATS_FILE"
	echo "config: $CONFIG_FILE"
	echo "fail_on_warn: $FAIL_ON_WARN"
	echo "max_fail: $MAX_FAIL"
	echo "max_ignored: $MAX_IGNORED"
	echo "max_missing: $MAX_MISSING"
	echo "max_severity: $MAX_SEVERITY"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CONFIG_FILE" ]; then
	echo "config_missing: $CONFIG_FILE" >>"$OUT_TXT"
	warn=$((warn + 1))
fi

if [ -f "$REPORT_FILE" ]; then
	result=$(grep -E '^result:' "$REPORT_FILE" | awk '{print $2}')
	if [ "$result" = "ok" ]; then
		echo "check_report: ok" >>"$OUT_TXT"
	else
		echo "check_report: warn" >>"$OUT_TXT"
		warn=$((warn + 1))
	fi
else
	echo "check_report: missing" >>"$OUT_TXT"
	warn=$((warn + 1))
fi

if [ -f "$REPORT_FILE" ]; then
	failures=$(grep -E '^check_failures:' "$REPORT_FILE" | awk '{print $2}')
	ignored=$(grep -E '^check_fail_ignored:' "$REPORT_FILE" | awk '{print $2}')
	missing=$(grep -E '^check_missing:' "$REPORT_FILE" | awk '{print $2}')
	failures=${failures:-0}
	ignored=${ignored:-0}
	missing=${missing:-0}
	echo "check_failures: $failures" >>"$OUT_TXT"
	echo "check_fail_ignored: $ignored" >>"$OUT_TXT"
	echo "check_missing: $missing" >>"$OUT_TXT"
	if [ "$MAX_FAIL" -ge 0 ] && [ "$failures" -gt "$MAX_FAIL" ]; then
		echo "threshold_failures: exceed" >>"$OUT_TXT"
		fail=$((fail + 1))
	fi
	if [ "$MAX_IGNORED" -ge 0 ] && [ "$ignored" -gt "$MAX_IGNORED" ]; then
		echo "threshold_ignored: exceed" >>"$OUT_TXT"
		fail=$((fail + 1))
	fi
	if [ "$MAX_MISSING" -ge 0 ] && [ "$missing" -gt "$MAX_MISSING" ]; then
		echo "threshold_missing: exceed" >>"$OUT_TXT"
		fail=$((fail + 1))
	fi
fi

if [ -f "$STATS_FILE" ]; then
	overall_severity=$(grep -E '^overall_severity:' "$STATS_FILE" | awk '{print $2}')
	overall_severity=${overall_severity:-0}
	echo "overall_severity: $overall_severity" >>"$OUT_TXT"
	if [ "$MAX_SEVERITY" -ge 0 ]; then
		if awk -v a="$overall_severity" -v b="$MAX_SEVERITY" 'BEGIN{exit !(a>b)}'; then
			echo "threshold_severity: exceed" >>"$OUT_TXT"
			fail=$((fail + 1))
		fi
	fi
else
	echo "stats_missing: $STATS_FILE" >>"$OUT_TXT"
	warn=$((warn + 1))
fi

if [ -f "$ROLLUP_FILE" ]; then
	result=$(grep -E '^result:' "$ROLLUP_FILE" | awk '{print $2}')
	if [ "$result" = "ok" ]; then
		echo "check_rollup: ok" >>"$OUT_TXT"
	else
		echo "check_rollup: warn" >>"$OUT_TXT"
		warn=$((warn + 1))
	fi
else
	echo "check_rollup: missing" >>"$OUT_TXT"
	warn=$((warn + 1))
fi

if [ "$fail" -gt 0 ]; then
	echo "result: fail" >>"$OUT_TXT"
	write_json "fail"
	exit 1
fi

if [ "$warn" -gt 0 ] && [ "$FAIL_ON_WARN" -eq 1 ]; then
	echo "result: fail" >>"$OUT_TXT"
	write_json "fail"
	exit 1
fi

if [ "$warn" -gt 0 ]; then
	echo "result: warn" >>"$OUT_TXT"
	write_json "warn"
else
	echo "result: ok" >>"$OUT_TXT"
	write_json "ok"
fi

echo "[OK] Build check gate generated: $OUT_TXT"
