#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SCORE_TXT="$REPORT_DIR/build_summary_alerts_stats_history_score.txt"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_score_validate.txt"

usage() {
	cat <<USAGE
Usage: $0 [--score <file>] [--out <file>]

Valide le score historique stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--score) SCORE_TXT="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history_score_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "score: $SCORE_TXT"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$SCORE_TXT" ]; then
	echo "result: missing_score" >>"$OUT_TXT"
	echo "score missing" >>"$OUT_TXT"
	exit 0
fi

score=$(grep -E '^score:' "$SCORE_TXT" | head -n 1 | awk '{print $2}')
score="${score:-0}"

if ! [[ "$score" =~ ^[0-9]+$ ]]; then
	echo "result: warn" >>"$OUT_TXT"
	echo "invalid_score" >>"$OUT_TXT"
	exit 0
fi

if [ "$score" -lt 0 ] || [ "$score" -gt 100 ]; then
	echo "result: warn" >>"$OUT_TXT"
	echo "score_out_of_range" >>"$OUT_TXT"
	exit 0
fi

echo "score: $score" >>"$OUT_TXT"
echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history score validate generated: $OUT_TXT"
