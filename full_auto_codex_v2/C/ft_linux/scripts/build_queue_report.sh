#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_queue_report.txt"

STATUS="$REPORT_DIR/build_queue_status.txt"
SUMMARY="$REPORT_DIR/build_queue_summary.txt"
METRICS="$REPORT_DIR/build_queue_metrics.txt"
RETRY="$REPORT_DIR/build_queue_retry_report.txt"
SYNC="$REPORT_DIR/build_queue_sync.txt"
STATE_VALIDATION="$REPORT_DIR/build_queue_state_validation.txt"
FAILURES="$REPORT_DIR/build_queue_failures.txt"

section() {
	local title="$1" file="$2"
	echo "## $title" >>"$OUT_TXT"
	if [ -f "$file" ]; then
		sed -n '1,40p' "$file" >>"$OUT_TXT"
	else
		echo "_missing: $file_" >>"$OUT_TXT"
	fi
	echo "" >>"$OUT_TXT"
}

{
	echo "build_queue report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
} >"$OUT_TXT"

section "Queue status" "$STATUS"
section "Queue summary" "$SUMMARY"
section "Queue metrics" "$METRICS"
section "Queue retry" "$RETRY"
section "Queue sync" "$SYNC"
section "Queue state validation" "$STATE_VALIDATION"
section "Queue failures" "$FAILURES"

result="ok"
if grep -qs '^result: warn' "$STATUS" "$METRICS" "$RETRY" "$SYNC" "$STATE_VALIDATION" "$FAILURES"; then
	result="warn"
fi
if grep -qs '^result: fail' "$SUMMARY"; then
	result="fail"
fi

echo "result: $result" >>"$OUT_TXT"
echo "[OK] Build queue report generated: $OUT_TXT"
