#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SUMMARY_TXT="$REPORT_DIR/build_check_regressions_summary.txt"
TRANSITIONS_TXT="$REPORT_DIR/build_check_regressions_transitions.txt"
OUT_TXT="$REPORT_DIR/build_check_regressions_score.txt"

usage() {
	cat <<EOF
Usage: $0 [--summary <file>] [--transitions <file>] [--out <file>]

Calcule un score simple de regressions (volume + rate + transitions).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--summary) SUMMARY_TXT="$2"; shift 2 ;;
		--transitions) TRANSITIONS_TXT="$2"; shift 2 ;;
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
	echo "build_check_regressions_score generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "summary: $SUMMARY_TXT"
	echo "transitions: $TRANSITIONS_TXT"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$SUMMARY_TXT" ]; then
	echo "result: missing_summary" >>"$OUT_TXT"
	echo "missing_summary: $SUMMARY_TXT" >>"$OUT_TXT"
	exit 0
fi

regressions=$(grep -E '^regressions:' "$SUMMARY_TXT" | head -n 1 | awk '{print $2}')
worst_rate=$(grep -E '^worst_rate:' "$SUMMARY_TXT" | head -n 1 | awk '{print $2}')
regressions=${regressions:-0}
worst_rate=${worst_rate:-0}

top_transition_count=0
if [ -f "$TRANSITIONS_TXT" ]; then
	top_transition_count=$(grep -E '^transition:' "$TRANSITIONS_TXT" | awk '{print $3}' | sort -nr | head -n 1)
	top_transition_count=${top_transition_count:-0}
fi

score=$(awk -v r="$regressions" -v w="$worst_rate" -v t="$top_transition_count" 'BEGIN{printf "%.2f", (r*2)+w+(t*0.5)}')

echo "regressions: $regressions" >>"$OUT_TXT"
echo "worst_rate: $worst_rate" >>"$OUT_TXT"
echo "top_transition_count: $top_transition_count" >>"$OUT_TXT"
echo "score: $score" >>"$OUT_TXT"

if awk -v s="$score" 'BEGIN{exit !(s>0)}'; then
	echo "result: warn" >>"$OUT_TXT"
else
	echo "result: ok" >>"$OUT_TXT"
fi

echo "[OK] Build check regressions score generated: $OUT_TXT"
