#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_report.txt"
OUT_CSV="$REPORT_DIR/build_summary_alerts_stats_export.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_export.txt"

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--csv <file>] [--out <file>]

Exporte les stats alertes en CSV.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
		--csv) OUT_CSV="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_export generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "report: $REPORT_FILE"
	echo "csv: $OUT_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$REPORT_FILE" ]; then
	echo "result: missing_report" >>"$OUT_TXT"
	echo "report missing" >>"$OUT_TXT"
	exit 0
fi

get_value() {
	local key="$1"
	grep -E "^${key}:" "$REPORT_FILE" | head -n 1 | awk '{print $2}'
}

alerts_total=$(get_value "alerts_total")
bundle_score=$(get_value "bundle_score")
stats_result=$(get_value "stats_result")
trend_avg_alerts=$(get_value "trend_avg_alerts")
trend_avg_score=$(get_value "trend_avg_score")
trend_warn=$(get_value "trend_warn")
trend_result=$(get_value "trend_result")
alerts_delta=$(get_value "alerts_delta")
score_delta=$(get_value "score_delta")
delta_result=$(get_value "delta_result")
result=$(get_value "result")

alerts_total="${alerts_total:-0}"
bundle_score="${bundle_score:-0}"
stats_result="${stats_result:-unknown}"
trend_avg_alerts="${trend_avg_alerts:-0}"
trend_avg_score="${trend_avg_score:-0}"
trend_warn="${trend_warn:-0}"
trend_result="${trend_result:-unknown}"
alerts_delta="${alerts_delta:-0}"
score_delta="${score_delta:-0}"
delta_result="${delta_result:-unknown}"
result="${result:-unknown}"

{
	echo "alerts_total,bundle_score,stats_result,trend_avg_alerts,trend_avg_score,trend_warn,trend_result,alerts_delta,score_delta,delta_result,result"
	echo "${alerts_total},${bundle_score},${stats_result},${trend_avg_alerts},${trend_avg_score},${trend_warn},${trend_result},${alerts_delta},${score_delta},${delta_result},${result}"
} >"$OUT_CSV"

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build summary alerts stats export generated: $OUT_TXT"
