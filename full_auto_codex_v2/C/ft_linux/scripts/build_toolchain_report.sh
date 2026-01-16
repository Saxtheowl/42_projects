#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
STATE_FILE="$ROOT/work/build_toolchain.state"
TIMING_LOG="$ROOT/logs/toolchain/build_times.csv"
OUT_TXT="$REPORT_DIR/build_toolchain_report.txt"

usage() {
	cat <<EOF
Usage: $0 [--state <file>] [--timing <file>] [--out <file>]

Synthese de l'etat toolchain + timings.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--state) STATE_FILE="$2"; shift 2 ;;
		--timing) TIMING_LOG="$2"; shift 2 ;;
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
	echo "build_toolchain_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "state: $STATE_FILE"
	echo "timing: $TIMING_LOG"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$STATE_FILE" ]; then
	echo "state_result: missing" >>"$OUT_TXT"
else
	done_steps=$(wc -l <"$STATE_FILE" | awk '{print $1}')
	echo "state_result: ok" >>"$OUT_TXT"
	echo "done_steps: ${done_steps:-0}" >>"$OUT_TXT"
	echo "steps: $(tr '\n' ' ' <"$STATE_FILE" | sed 's/ $//')" >>"$OUT_TXT"
fi

if [ -f "$TIMING_LOG" ]; then
	echo "" >>"$OUT_TXT"
	echo "timing_summary:" >>"$OUT_TXT"
	awk -F',' 'NR>1 {sum+=$6; ok+=($7=="ok"); fail+=($7=="fail"); count++}
		END {
			printf "count: %d\n", count+0;
			printf "ok: %d\n", ok+0;
			printf "fail: %d\n", fail+0;
			printf "total_sec: %d\n", sum+0;
		}' "$TIMING_LOG" >>"$OUT_TXT"
else
	echo "" >>"$OUT_TXT"
	echo "timing_result: missing" >>"$OUT_TXT"
fi

if grep -q 'fail' "$OUT_TXT"; then
	echo "result: warn" >>"$OUT_TXT"
elif grep -q 'missing' "$OUT_TXT"; then
	echo "result: partial" >>"$OUT_TXT"
else
	echo "result: ok" >>"$OUT_TXT"
fi

echo "[OK] Build toolchain report generated: $OUT_TXT"
