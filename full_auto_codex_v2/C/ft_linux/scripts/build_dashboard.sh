#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
STATUS_FILE="$REPORT_DIR/status_assessment.txt"
CHECK_GATE_FILE="$REPORT_DIR/build_check_gate.txt"
CHECK_REPORT_FILE="$REPORT_DIR/build_check_report.txt"
CHECK_STATS_FILE="$REPORT_DIR/build_check_stats.txt"
OUT_TXT="$REPORT_DIR/build_dashboard.txt"

usage() {
	cat <<EOF
Usage: $0 [--status <file>] [--out <file>]

Genere un tableau de bord a partir de status_assessment.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--status) STATUS_FILE="$2"; shift 2 ;;
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
	echo "build_dashboard generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "status_file: $STATUS_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$STATUS_FILE" ]; then
	echo "result: missing_status" >>"$OUT_TXT"
	echo "status_assessment missing" >>"$OUT_TXT"
	exit 0
fi

overall="ok"
actions=""

while IFS= read -r line || [ -n "$line" ]; do
	case "$line" in
		""|Status*|date:*|Notes:*) continue ;;
	esac
	label=$(printf '%s' "$line" | awk '{print $1}')
	result=$(printf '%s' "$line" | awk '{print $2}')
	if [ "$result" = "missing" ]; then
		overall="warn"
		actions+="- ${label}: generer le rapport manquant\n"
	elif [ "$result" = "warn" ]; then
		overall="warn"
		actions+="- ${label}: verifier les details du rapport\n"
	fi
done <"$STATUS_FILE"

echo "result: $overall" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"
echo "checks:" >>"$OUT_TXT"
if [ -f "$CHECK_GATE_FILE" ]; then
	gate_result=$(grep -E '^result:' "$CHECK_GATE_FILE" | awk '{print $2}')
	failures=$(grep -E '^check_failures:' "$CHECK_GATE_FILE" | awk '{print $2}')
	ignored=$(grep -E '^check_fail_ignored:' "$CHECK_GATE_FILE" | awk '{print $2}')
	missing=$(grep -E '^check_missing:' "$CHECK_GATE_FILE" | awk '{print $2}')
	echo "- check_gate: ${gate_result:-unknown} (fail=${failures:-0} ignored=${ignored:-0} missing=${missing:-0})" >>"$OUT_TXT"
else
	echo "- check_gate: missing ($CHECK_GATE_FILE)" >>"$OUT_TXT"
fi
if [ -f "$CHECK_REPORT_FILE" ]; then
	report_result=$(grep -E '^result:' "$CHECK_REPORT_FILE" | awk '{print $2}')
	report_fail=$(grep -E '^check_failures:' "$CHECK_REPORT_FILE" | awk '{print $2}')
	report_ign=$(grep -E '^check_fail_ignored:' "$CHECK_REPORT_FILE" | awk '{print $2}')
	report_miss=$(grep -E '^check_missing:' "$CHECK_REPORT_FILE" | awk '{print $2}')
	echo "- check_report: ${report_result:-unknown} (fail=${report_fail:-0} ignored=${report_ign:-0} missing=${report_miss:-0})" >>"$OUT_TXT"
else
	echo "- check_report: missing ($CHECK_REPORT_FILE)" >>"$OUT_TXT"
fi
if [ -f "$CHECK_STATS_FILE" ]; then
	stats_fail_rate=$(grep -E '^fail_rate:' "$CHECK_STATS_FILE" | head -n 1 | awk '{print $2}')
	stats_ignored_rate=$(grep -E '^ignored_rate:' "$CHECK_STATS_FILE" | head -n 1 | awk '{print $2}')
	echo "- check_stats: fail_rate=${stats_fail_rate:-0} ignored_rate=${stats_ignored_rate:-0}" >>"$OUT_TXT"
else
	echo "- check_stats: missing ($CHECK_STATS_FILE)" >>"$OUT_TXT"
fi
echo "" >>"$OUT_TXT"
echo "actions:" >>"$OUT_TXT"
if [ -n "$actions" ]; then
	printf '%b' "$actions" >>"$OUT_TXT"
else
	echo "- aucun" >>"$OUT_TXT"
fi

echo "[OK] Build dashboard generated: $OUT_TXT"
