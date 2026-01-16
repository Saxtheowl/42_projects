#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/build_toolchain_report.txt"
OUT_JSON="$REPORT_DIR/build_toolchain_report.json"
OUT_TXT="$REPORT_DIR/build_toolchain_report_json.txt"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--json <file>] [--out <file>]

Exporte un JSON du rapport toolchain.
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
	echo "build_toolchain_report_json generated: $(date '+%Y-%m-%d %H:%M:%S')"
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

state_result=$(grep -E '^state_result:' "$IN_TXT" | head -n 1 | awk '{print $2}')
done_steps=$(grep -E '^done_steps:' "$IN_TXT" | head -n 1 | awk '{print $2}')
timing_count=$(grep -E '^count:' "$IN_TXT" | head -n 1 | awk '{print $2}')
timing_ok=$(grep -E '^ok:' "$IN_TXT" | head -n 1 | awk '{print $2}')
timing_fail=$(grep -E '^fail:' "$IN_TXT" | head -n 1 | awk '{print $2}')
timing_total=$(grep -E '^total_sec:' "$IN_TXT" | head -n 1 | awk '{print $2}')
result=$(grep -E '^result:' "$IN_TXT" | head -n 1 | awk '{print $2}')

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$IN_TXT\","
	echo "  \"state_result\": \"${state_result:-unknown}\","
	echo "  \"done_steps\": ${done_steps:-0},"
	echo "  \"timing\": {"
	echo "    \"count\": ${timing_count:-0},"
	echo "    \"ok\": ${timing_ok:-0},"
	echo "    \"fail\": ${timing_fail:-0},"
	echo "    \"total_sec\": ${timing_total:-0}"
	echo "  },"
	echo "  \"result\": \"${result:-unknown}\""
	echo "}"
} >"$OUT_JSON"

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build toolchain report JSON generated: $OUT_TXT"
