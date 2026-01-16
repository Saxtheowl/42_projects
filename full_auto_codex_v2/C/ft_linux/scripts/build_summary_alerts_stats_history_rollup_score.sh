#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
ROLLUP_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.json"

usage() {
	cat <<USAGE
Usage: $0 [--rollup <file>] [--out <file>] [--json <file>]

Calcule un score de stabilite a partir du rollup historique.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--rollup) ROLLUP_FILE="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_stats_history_rollup_score generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "rollup: $ROLLUP_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$ROLLUP_FILE" ]; then
	echo "result: missing_rollup" >>"$OUT_TXT"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$ROLLUP_FILE\","
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	exit 0
fi

get_value() {
	local key="$1"
	grep -E "^${key}:" "$ROLLUP_FILE" | head -n 1 | awk '{print $2}'
}

entries=$(get_value "entries")
window=$(get_value "window")
delta_alerts=$(get_value "delta_alerts")
delta_score=$(get_value "delta_score")

entries="${entries:-0}"
window="${window:-0}"
delta_alerts="${delta_alerts:-0}"
delta_score="${delta_score:-0}"

score=$(awk -v da="$delta_alerts" -v ds="$delta_score" '
	BEGIN {
		pa = (da > 0 ? da : 0)
		ps = (ds < 0 ? -ds : 0)
		s = 100 - (pa * 5) - (ps * 10)
		if (s < 0) s = 0
		printf "%.0f", s
	}
')

result="ok"
if [ "$entries" -lt "$window" ]; then
	result="warn"
fi
if [ "$score" -lt 80 ]; then
	result="warn"
fi

{
	echo "entries: $entries"
	echo "window: $window"
	echo "delta_alerts: $delta_alerts"
	echo "delta_score: $delta_score"
	echo "score: $score"
	echo "result: $result"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$ROLLUP_FILE\","
	echo "  \"entries\": $entries,"
	echo "  \"window\": $window,"
	echo "  \"delta_alerts\": $delta_alerts,"
	echo "  \"delta_score\": $delta_score,"
	echo "  \"score\": $score,"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts stats history rollup score generated: $OUT_TXT"
