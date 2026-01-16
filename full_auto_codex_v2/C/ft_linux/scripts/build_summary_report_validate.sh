#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_report.txt"
OUT_TXT="$REPORT_DIR/build_summary_report_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--out <file>]

Valide la presence des lignes cles dans build_summary_report.txt.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
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
	echo "build_summary_report_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "report: $REPORT_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$REPORT_FILE" ]; then
	echo "result: missing_report" >>"$OUT_TXT"
	echo "report missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
for key in overall gate gate_validate check_failures check_missing toolchain_session preflight_gate summary_alerts summary_alerts_stats summary_alerts_stats_history_report summary_alerts_stats_history_table summary_alerts_stats_history_score summary_alerts_stats_history_anomalies summary_alerts_stats_history_rollup summary_alerts_stats_history_rollup_score summary_alerts_stats_history_rollup_bundle summary_alerts_stats_history_rollup_overview summary_alerts_stats_history_rollup_history summary_alerts_stats_history_rollup_history_csv_validate summary_alerts_stats_history_rollup_trend summary_alerts_stats_trend summary_alerts_stats_delta summary_alerts_items_trend summary_alerts_items_delta summary_alerts_items_report summary_alerts_items_overview summary_bundle summary_bundle_index_trend summary_bundle_index_delta summary_bundle_index_overview summary_bundle_index_score summary_alerts_stats_report result; do
	if ! grep -q "^${key}:" "$REPORT_FILE"; then
		echo "missing_line: $key" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary report validate generated: $OUT_TXT"
