#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_health_report.txt"

REPORTS=(
	"$REPORT_DIR/status_assessment.txt"
	"$REPORT_DIR/build_dashboard.txt"
	"$REPORT_DIR/build_progress_rollup.txt"
	"$REPORT_DIR/build_queue_report.txt"
	"$REPORT_DIR/build_queue_metrics.txt"
	"$REPORT_DIR/build_check_report.txt"
	"$REPORT_DIR/build_check_status_report.txt"
	"$REPORT_DIR/build_check_status_rollup.txt"
	"$REPORT_DIR/build_check_gate.txt"
	"$REPORT_DIR/build_check_trend.txt"
	"$REPORT_DIR/build_check_prune.txt"
	"$REPORT_DIR/build_check_stats.txt"
	"$REPORT_DIR/build_check_summary_validate.txt"
	"$REPORT_DIR/build_check_export.csv"
	"$REPORT_DIR/build_check_coverage.txt"
	"$REPORT_DIR/build_check_snapshot.txt"
	"$REPORT_DIR/build_check_snapshot_list.txt"
	"$REPORT_DIR/build_check_snapshot_prune.txt"
	"$REPORT_DIR/build_check_snapshot_diff.txt"
	"$REPORT_DIR/build_orchestrator_status.txt"
	"$REPORT_DIR/build_gate.txt"
)

usage() {
	cat <<EOF
Usage: $0 [--out <file>]

Synthese sante build (compte ok/warn/missing).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
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
	echo "build_health_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
} >"$OUT_TXT"

ok=0
warn=0
missing=0
unknown=0

for report in "${REPORTS[@]}"; do
	name="$(basename "$report")"
	if [ ! -f "$report" ]; then
		echo "$name: missing" >>"$OUT_TXT"
		missing=$((missing + 1))
		continue
	fi
	result=$(grep -E '^result:' "$report" | head -n 1 | awk '{print $2}')
	if [ -z "$result" ]; then
		echo "$name: unknown" >>"$OUT_TXT"
		unknown=$((unknown + 1))
	elif [ "$result" = "ok" ]; then
		echo "$name: ok" >>"$OUT_TXT"
		ok=$((ok + 1))
	elif [ "$result" = "warn" ] || [ "$result" = "partial" ] || [ "$result" = "retry_available" ]; then
		echo "$name: warn" >>"$OUT_TXT"
		warn=$((warn + 1))
	else
		echo "$name: $result" >>"$OUT_TXT"
		warn=$((warn + 1))
	fi
done

{
	echo ""
	echo "ok: $ok"
	echo "warn: $warn"
	echo "missing: $missing"
	echo "unknown: $unknown"
} >>"$OUT_TXT"

overall="ok"
if [ "$warn" -gt 0 ] || [ "$missing" -gt 0 ] || [ "$unknown" -gt 0 ]; then
	overall="warn"
fi
echo "result: $overall" >>"$OUT_TXT"

echo "[OK] Build health report generated: $OUT_TXT"
