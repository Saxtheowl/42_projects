#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAN="$ROOT/reports/build_plan.sh"
STATE_FILE="$ROOT/work/build_queue.state"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_queue.txt"
OUT_CSV="$REPORT_DIR/build_queue.csv"
OUT_SUMMARY="$REPORT_DIR/build_queue_summary.txt"
OUT_STATUS="$REPORT_DIR/build_queue_status.txt"
LOG_FILE="$ROOT/logs/build_queue.log"
DRY_RUN=0
RESUME=0
SHOW_STATUS=0
RESET_STATE=0
TIMEOUT=0
CONTINUE_ON_FAIL=0

usage() {
	cat <<EOF
Usage: $0 [--plan <file>] [--state <file>] [--dry-run] [--resume] [--status] [--reset-state] [--timeout <sec>] [--continue-on-fail]

Execute un plan de build (liste de commandes) avec suivi d'etat.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--plan) PLAN="$2"; shift 2 ;;
		--state) STATE_FILE="$2"; shift 2 ;;
		--dry-run) DRY_RUN=1; shift ;;
		--resume) RESUME=1; shift ;;
		--status) SHOW_STATUS=1; shift ;;
		--reset-state) RESET_STATE=1; shift ;;
		--timeout) TIMEOUT="$2"; shift 2 ;;
		--continue-on-fail) CONTINUE_ON_FAIL=1; shift ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR" "$(dirname "$STATE_FILE")" "$(dirname "$LOG_FILE")"

if [ ! -f "$PLAN" ]; then
	echo "[ERR] Plan introuvable: $PLAN" >&2
	exit 1
fi

should_skip() {
	local cmd="$1"
	if [ "$RESUME" -eq 1 ] && [ -f "$STATE_FILE" ]; then
		grep -Fxq "$cmd" "$STATE_FILE"
		return
	fi
	return 1
}

record_state() {
	local cmd="$1"
	echo "$cmd" >>"$STATE_FILE"
}

reset_state() {
	if [ -f "$STATE_FILE" ]; then
		rm -f "$STATE_FILE"
		echo "[i] state reset: $STATE_FILE"
	else
		echo "[i] state absent: $STATE_FILE"
	fi
}

status_report() {
	local total done pending_list pending_count
	total=$(grep -v '^[[:space:]]*$' "$PLAN" | grep -v '^[[:space:]]*#' | wc -l | tr -d ' ')
	if [ -f "$STATE_FILE" ]; then
		done=$(sort -u "$STATE_FILE" | wc -l | tr -d ' ')
	else
		done=0
	fi
	pending_list=$(grep -v '^[[:space:]]*$' "$PLAN" | grep -v '^[[:space:]]*#' | while IFS= read -r cmd; do
		if [ -f "$STATE_FILE" ] && grep -Fxq "$cmd" "$STATE_FILE"; then
			continue
		fi
		echo "$cmd"
	done)
	if [ -n "$pending_list" ]; then
		pending_count=$(printf '%s\n' "$pending_list" | wc -l | tr -d ' ')
	else
		pending_count=0
	fi
	{
		echo "build_queue status: $(date '+%Y-%m-%d %H:%M:%S')"
		echo "plan: $PLAN"
		echo "state: $STATE_FILE"
		echo "total: $total"
		echo "done: $done"
		echo "pending: $pending_count"
		if [ "$pending_count" -eq 0 ]; then
			echo "result: ok"
		else
			echo "result: partial"
		fi
		echo ""
		echo "pending_list:"
		if [ -n "$pending_list" ]; then
			echo "$pending_list"
		else
			echo "none"
		fi
	} >"$OUT_STATUS"
	echo "[OK] Build queue status generated: $OUT_STATUS"
}

if [ "$RESET_STATE" -eq 1 ]; then
	reset_state
fi

if [ "$SHOW_STATUS" -eq 1 ]; then
	status_report
	exit 0
fi

if [ "$RESET_STATE" -eq 1 ]; then
	exit 0
fi

{
	echo "build_queue run: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "plan: $PLAN"
	echo "state: $STATE_FILE"
	echo "dry_run: $DRY_RUN"
	echo "resume: $RESUME"
	echo "timeout: $TIMEOUT"
	echo "continue_on_fail: $CONTINUE_ON_FAIL"
	echo ""
} >"$OUT_TXT"

echo "command,start,end,duration_sec,status" >"$OUT_CSV"

total=0
skipped=0
ok=0
failed=0
last_failed=""

while IFS= read -r line || [ -n "$line" ]; do
	case "$line" in
		""|\#*) continue ;;
	esac
	total=$((total + 1))
	if should_skip "$line"; then
		skipped=$((skipped + 1))
		echo "[skip] $line" | tee -a "$OUT_TXT" "$LOG_FILE" >/dev/null
		printf '%s,,,,skip\n' "$line" >>"$OUT_CSV"
		continue
	fi
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "[dry-run] $line" | tee -a "$OUT_TXT" "$LOG_FILE" >/dev/null
		printf '%s,,,,dry-run\n' "$line" >>"$OUT_CSV"
		continue
	fi
	echo "[run] $line" | tee -a "$OUT_TXT" "$LOG_FILE" >/dev/null
	start=$(date +%s)
	if [ "$TIMEOUT" -gt 0 ]; then
		timeout "$TIMEOUT" bash -c "$line" >>"$LOG_FILE" 2>&1
		cmd_status=$?
	else
		bash -c "$line" >>"$LOG_FILE" 2>&1
		cmd_status=$?
	fi
	if [ "$cmd_status" -eq 0 ]; then
		end=$(date +%s)
		duration=$((end - start))
		record_state "$line"
		ok=$((ok + 1))
		printf '%s,%s,%s,%s,ok\n' "$line" "$start" "$end" "$duration" >>"$OUT_CSV"
		echo "[ok] $line" | tee -a "$OUT_TXT" "$LOG_FILE" >/dev/null
	else
		end=$(date +%s)
		duration=$((end - start))
		failed=$((failed + 1))
		if [ "$TIMEOUT" -gt 0 ] && [ "$cmd_status" -eq 124 ]; then
			printf '%s,%s,%s,%s,timeout\n' "$line" "$start" "$end" "$duration" >>"$OUT_CSV"
		else
			printf '%s,%s,%s,%s,fail\n' "$line" "$start" "$end" "$duration" >>"$OUT_CSV"
		fi
		echo "[fail] $line" | tee -a "$OUT_TXT" "$LOG_FILE" >/dev/null
		last_failed="$line"
		if [ "$CONTINUE_ON_FAIL" -eq 0 ]; then
			{
				echo "build_queue summary: $(date '+%Y-%m-%d %H:%M:%S')"
				echo "total: $total"
				echo "ok: $ok"
				echo "skipped: $skipped"
				echo "failed: $failed"
				echo "result: fail"
				echo "failed_command: $line"
			} >"$OUT_SUMMARY"
			exit 1
		fi
	fi
done <"$PLAN"

{
	echo "build_queue summary: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "total: $total"
	echo "ok: $ok"
	echo "skipped: $skipped"
	echo "failed: $failed"
	if [ "$failed" -eq 0 ]; then
		echo "result: ok"
	else
		echo "result: warn"
		if [ -n "$last_failed" ]; then
			echo "failed_command: $last_failed"
		fi
	fi
} >"$OUT_SUMMARY"

echo "[OK] Build queue completed: $OUT_TXT"
