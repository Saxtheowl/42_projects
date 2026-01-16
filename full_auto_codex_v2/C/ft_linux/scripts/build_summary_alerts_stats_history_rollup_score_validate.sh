#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
JSON_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score_validate.txt"

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--json <file>] [--out <file>]

Valide le score de stabilite du rollup historique.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
		--json) JSON_FILE="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history_rollup_score_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "report: $REPORT_FILE"
	echo "json: $JSON_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$REPORT_FILE" ]; then
	echo "result: missing_report" >>"$OUT_TXT"
	echo "report missing" >>"$OUT_TXT"
	exit 0
fi

if ! grep -qE '^result:' "$REPORT_FILE"; then
	echo "result: warn" >>"$OUT_TXT"
	echo "missing_result_line" >>"$OUT_TXT"
	exit 0
fi

if [ ! -f "$JSON_FILE" ]; then
	echo "result: warn" >>"$OUT_TXT"
	echo "json missing" >>"$OUT_TXT"
	exit 0
fi

for key in result score; do
	if ! grep -q "\"$key\"" "$JSON_FILE"; then
		echo "result: warn" >>"$OUT_TXT"
		echo "json_missing_$key" >>"$OUT_TXT"
		exit 0
	fi
done

echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history rollup score validate generated: $OUT_TXT"
