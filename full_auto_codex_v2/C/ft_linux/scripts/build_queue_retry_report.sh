#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SUMMARY="$REPORT_DIR/build_queue_summary.txt"
OUT_TXT="$REPORT_DIR/build_queue_retry_report.txt"

usage() {
	cat <<EOF
Usage: $0 [--summary <file>] [--out <file>]

Rapport sur la derniere commande en echec du build_queue.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--summary) SUMMARY="$2"; shift 2 ;;
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
	echo "build_queue_retry_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "summary: $SUMMARY"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$SUMMARY" ]; then
	echo "result: missing_summary" >>"$OUT_TXT"
	echo "summary missing" >>"$OUT_TXT"
	exit 0
fi

failed_cmd=$(awk -F': ' '/^failed_command:/ {print $2}' "$SUMMARY" | head -n 1)
if [ -z "$failed_cmd" ]; then
	echo "result: ok" >>"$OUT_TXT"
	echo "no failed_command" >>"$OUT_TXT"
else
	echo "result: retry_available" >>"$OUT_TXT"
	echo "failed_command: $failed_cmd" >>"$OUT_TXT"
fi

echo "[OK] Build queue retry report generated: $OUT_TXT"
