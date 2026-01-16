#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SUMMARY="$REPORT_DIR/build_queue_summary.txt"
STATE_FILE="$ROOT/work/build_queue.state"
LOG_FILE="$ROOT/logs/build_queue.log"
OUT_TXT="$REPORT_DIR/build_queue_retry.txt"
DRY_RUN=0

usage() {
	cat <<EOF
Usage: $0 [--summary <file>] [--state <file>] [--dry-run]

Relance la derniere commande en echec du build_queue.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--summary) SUMMARY="$2"; shift 2 ;;
		--state) STATE_FILE="$2"; shift 2 ;;
		--dry-run) DRY_RUN=1; shift ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR" "$(dirname "$STATE_FILE")" "$(dirname "$LOG_FILE")"

{
	echo "build_queue_retry run: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "summary: $SUMMARY"
	echo "state: $STATE_FILE"
	echo "dry_run: $DRY_RUN"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$SUMMARY" ]; then
	echo "result: missing_summary" >>"$OUT_TXT"
	echo "[WARN] Summary introuvable." >>"$OUT_TXT"
	exit 0
fi

failed_cmd=$(awk -F': ' '/^failed_command:/ {print $2}' "$SUMMARY" | head -n 1)
if [ -z "$failed_cmd" ]; then
	echo "result: nothing_to_retry" >>"$OUT_TXT"
	echo "[INFO] Aucun failed_command dans le summary." >>"$OUT_TXT"
	exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
	echo "result: dry_run" >>"$OUT_TXT"
	echo "[dry-run] $failed_cmd" >>"$OUT_TXT"
	exit 0
fi

echo "[run] $failed_cmd" | tee -a "$OUT_TXT" "$LOG_FILE" >/dev/null
start=$(date +%s)
if bash -c "$failed_cmd" >>"$LOG_FILE" 2>&1; then
	end=$(date +%s)
	duration=$((end - start))
	echo "$failed_cmd" >>"$STATE_FILE"
	{
		echo "result: ok"
		echo "duration_sec: $duration"
		echo "command: $failed_cmd"
	} >>"$OUT_TXT"
	echo "[ok] $failed_cmd" | tee -a "$OUT_TXT" "$LOG_FILE" >/dev/null
else
	end=$(date +%s)
	duration=$((end - start))
	{
		echo "result: fail"
		echo "duration_sec: $duration"
		echo "command: $failed_cmd"
	} >>"$OUT_TXT"
	echo "[fail] $failed_cmd" | tee -a "$OUT_TXT" "$LOG_FILE" >/dev/null
	exit 1
fi

echo "[OK] Build queue retry report: $OUT_TXT"
