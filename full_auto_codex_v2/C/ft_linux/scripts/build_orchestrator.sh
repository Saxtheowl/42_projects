#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
PLAN="$REPORT_DIR/build_plan.sh"
PLAN_SPLIT_DIR="$REPORT_DIR/build_plan_splits"
PLAN_SPLIT_INDEX="$REPORT_DIR/build_plan_splits.txt"
QUEUE_STATE="$ROOT/work/build_queue.state"
LFS="${LFS:-$ROOT/.lfs}"

CHUNK_SIZE=0
TIMEOUT=0
RESUME=0
DRY_RUN=0
REFRESH_PLAN=0
OUT_TXT="$REPORT_DIR/build_orchestrator.txt"
OUT_JSON="$REPORT_DIR/build_orchestrator.json"
PLAN_WITH_CHECK=0
PLAN_CHECK_ALLOW_FAIL=0

usage() {
	cat <<EOF
Usage: $0 [--refresh-plan] [--chunk-size <n>] [--timeout <sec>] [--resume] [--dry-run] [--plan <file>] [--queue-state <file>] [--lfs <dir>] [--json <file>] [--plan-check] [--plan-check-allow-fail]

Orchestre le build: plan -> (optionnel split) -> build_queue -> sync states -> run_reports.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--refresh-plan) REFRESH_PLAN=1; shift ;;
		--chunk-size) CHUNK_SIZE="$2"; shift 2 ;;
		--timeout) TIMEOUT="$2"; shift 2 ;;
		--resume) RESUME=1; shift ;;
		--dry-run) DRY_RUN=1; shift ;;
		--plan) PLAN="$2"; shift 2 ;;
		--queue-state) QUEUE_STATE="$2"; shift 2 ;;
		--lfs) LFS="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		--plan-check) PLAN_WITH_CHECK=1; shift ;;
		--plan-check-allow-fail) PLAN_CHECK_ALLOW_FAIL=1; shift ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_orchestrator generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "plan: $PLAN"
	echo "queue_state: $QUEUE_STATE"
	echo "chunk_size: $CHUNK_SIZE"
	echo "timeout: $TIMEOUT"
	echo "resume: $RESUME"
	echo "dry_run: $DRY_RUN"
	echo "lfs: $LFS"
	echo "plan_check: $PLAN_WITH_CHECK"
	echo "plan_check_allow_fail: $PLAN_CHECK_ALLOW_FAIL"
	echo ""
} >"$OUT_TXT"

json_escape() {
	local value="$1"
	value=${value//\\/\\\\}
	value=${value//\"/\\\"}
	value=${value//$'\n'/\\n}
	echo "$value"
}

write_json() {
	local result="$1"
	local failed_key="${2:-}"
	local failed_val="${3:-}"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"plan\": \"$(json_escape "$PLAN")\","
		echo "  \"queue_state\": \"$(json_escape "$QUEUE_STATE")\","
		echo "  \"chunk_size\": $CHUNK_SIZE,"
		echo "  \"timeout\": $TIMEOUT,"
		echo "  \"resume\": $RESUME,"
		echo "  \"dry_run\": $DRY_RUN,"
		echo "  \"lfs\": \"$(json_escape "$LFS")\","
		echo "  \"result\": \"$(json_escape "$result")\""
		if [ -n "$failed_key" ] && [ -n "$failed_val" ]; then
			echo "  ,\"$failed_key\": \"$(json_escape "$failed_val")\""
		fi
		echo "}"
	} >"$OUT_JSON"
}

write_json "running"

if [ "$REFRESH_PLAN" -eq 1 ] || [ ! -f "$PLAN" ]; then
	plan_cmd=( "$ROOT/scripts/build_plan.sh" --out "$PLAN" --text "$REPORT_DIR/build_plan.txt" )
	if [ "$PLAN_WITH_CHECK" -eq 1 ]; then
		plan_cmd+=( --with-check )
	fi
	if [ "$PLAN_CHECK_ALLOW_FAIL" -eq 1 ]; then
		plan_cmd+=( --check-allow-fail )
	fi
	"${plan_cmd[@]}"
fi

if [ "$CHUNK_SIZE" -gt 0 ]; then
	"$ROOT/scripts/build_plan_split.sh" --plan "$PLAN" --chunk-size "$CHUNK_SIZE" --out-dir "$PLAN_SPLIT_DIR" --out "$PLAN_SPLIT_INDEX"
	if [ ! -f "$PLAN_SPLIT_INDEX" ]; then
		echo "result: missing_splits" >>"$OUT_TXT"
		echo "[ERR] build_plan_splits.txt manquant." >>"$OUT_TXT"
		exit 1
	fi
	chunks=$(grep -v '^[[:space:]]*$' "$PLAN_SPLIT_INDEX" | grep -v '^[[:space:]]*#' || true)
	if [ -z "$chunks" ]; then
		echo "result: empty_splits" >>"$OUT_TXT"
		echo "[ERR] Aucun chunk genere." >>"$OUT_TXT"
		exit 1
	fi
	for chunk in $chunks; do
		echo "chunk: $chunk" >>"$OUT_TXT"
		cmd=( "$ROOT/scripts/build_queue.sh" --plan "$chunk" --state "$QUEUE_STATE" )
		if [ "$RESUME" -eq 1 ]; then
			cmd+=( --resume )
		fi
		if [ "$DRY_RUN" -eq 1 ]; then
			cmd+=( --dry-run )
		fi
		if [ "$TIMEOUT" -gt 0 ]; then
			cmd+=( --timeout "$TIMEOUT" )
		fi
		if ! "${cmd[@]}"; then
			echo "result: fail" >>"$OUT_TXT"
			echo "failed_chunk: $chunk" >>"$OUT_TXT"
			write_json "fail" "failed_chunk" "$chunk"
			exit 1
		fi
	done
else
	cmd=( "$ROOT/scripts/build_queue.sh" --plan "$PLAN" --state "$QUEUE_STATE" )
	if [ "$RESUME" -eq 1 ]; then
		cmd+=( --resume )
	fi
	if [ "$DRY_RUN" -eq 1 ]; then
		cmd+=( --dry-run )
	fi
	if [ "$TIMEOUT" -gt 0 ]; then
		cmd+=( --timeout "$TIMEOUT" )
	fi
	if ! "${cmd[@]}"; then
		echo "result: fail" >>"$OUT_TXT"
		echo "failed_plan: $PLAN" >>"$OUT_TXT"
		write_json "fail" "failed_plan" "$PLAN"
		exit 1
	fi
fi

"$ROOT/scripts/build_queue_sync_states.sh" --apply || true
"$ROOT/scripts/run_reports.sh" --lfs "$LFS" || true

echo "result: ok" >>"$OUT_TXT"
write_json "ok"
echo "[OK] Build orchestrator completed: $OUT_TXT"
