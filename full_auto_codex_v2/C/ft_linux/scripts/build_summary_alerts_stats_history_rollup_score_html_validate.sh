#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HTML_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.html"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score_html_validate.txt"

usage() {
	cat <<USAGE
Usage: $0 [--html <file>] [--out <file>]

Valide le rapport HTML du score rollup.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--html) HTML_FILE="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history_rollup_score_html_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "html: $HTML_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HTML_FILE" ]; then
	echo "result: missing_html" >>"$OUT_TXT"
	echo "html missing" >>"$OUT_TXT"
	exit 0
fi

if ! grep -q "<title>Build Summary Alerts Stats History Rollup Score</title>" "$HTML_FILE"; then
	echo "result: warn" >>"$OUT_TXT"
	echo "missing_title" >>"$OUT_TXT"
	exit 0
fi

echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history rollup score HTML validate generated: $OUT_TXT"
