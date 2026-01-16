#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
STATS_FILE="$REPORT_DIR/build_check_stats.txt"
TREND_FILE="$REPORT_DIR/build_check_trend.txt"
OUT_CSV="$REPORT_DIR/build_check_export.csv"

usage() {
	cat <<EOF
Usage: $0 [--stats <file>] [--trend <file>] [--out <file>]

Exporte une synthese CSV des checks (global + dernier jour).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--stats) STATS_FILE="$2"; shift 2 ;;
		--trend) TREND_FILE="$2"; shift 2 ;;
		--out) OUT_CSV="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

overall_total=$(grep -E '^total_packages:' "$STATS_FILE" 2>/dev/null | awk '{print $2}')
overall_ok=$(grep -E '^ok:' "$STATS_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')
overall_fail=$(grep -E '^fail:' "$STATS_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')
overall_ignored=$(grep -E '^fail_ignored:' "$STATS_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')
overall_other=$(grep -E '^other:' "$STATS_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')
overall_fail_rate=$(grep -E '^fail_rate:' "$STATS_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')
overall_ignored_rate=$(grep -E '^ignored_rate:' "$STATS_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')
overall_severity=$(grep -E '^overall_severity:' "$STATS_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')

trend_line=$(awk '
	/^\[day:/ {gsub(/^\[day:|\]$/, "", $0); day=$0}
	/^ok:/ {ok=$2}
	/^fail:/ {fail=$2}
	/^fail_ignored:/ {ign=$2}
	/^other:/ {other=$2}
	/^total:/ {total=$2}
	END {if (day!="") printf "%s,%s,%s,%s,%s,%s", day, ok+0, fail+0, ign+0, other+0, total+0}
' "$TREND_FILE" 2>/dev/null || true)

trend_day=""
trend_ok=0
trend_fail=0
trend_ign=0
trend_other=0
trend_total=0
if [ -n "$trend_line" ]; then
	IFS=',' read -r trend_day trend_ok trend_fail trend_ign trend_other trend_total <<<"$trend_line"
fi

{
	echo "kind,total,ok,fail,fail_ignored,other,fail_rate,ignored_rate,overall_severity,day"
	echo "overall,${overall_total:-0},${overall_ok:-0},${overall_fail:-0},${overall_ignored:-0},${overall_other:-0},${overall_fail_rate:-0},${overall_ignored_rate:-0},${overall_severity:-0},"
	if [ -n "$trend_line" ]; then
		trend_fail_rate=0
		trend_ignored_rate=0
		if [ "${trend_total:-0}" -gt 0 ]; then
			trend_fail_rate=$(awk -v a="$trend_fail" -v b="$trend_total" 'BEGIN{printf "%.2f", (a*100)/b}')
			trend_ignored_rate=$(awk -v a="$trend_ign" -v b="$trend_total" 'BEGIN{printf "%.2f", (a*100)/b}')
		fi
		echo "trend_last,${trend_total:-0},${trend_ok:-0},${trend_fail:-0},${trend_ign:-0},${trend_other:-0},${trend_fail_rate},${trend_ignored_rate},0,${trend_day}"
	else
		echo "trend_last,0,0,0,0,0,0,0,0,"
	fi
} >"$OUT_CSV"

if [ -f "$STATS_FILE" ]; then
	awk '
		/^\[group:/ {g=$0; sub(/^\[group:/,"",g); sub(/\]$/,"",g)}
		/^packages:/ {total=$2}
		/^ok:/ {ok=$2}
		/^fail:/ {fail=$2}
		/^fail_ignored:/ {ign=$2}
		/^other:/ {other=$2}
		/^fail_rate:/ {fail_rate=$2}
		/^ignored_rate:/ {ignored_rate=$2}
		/^severity:/ {
			severity=$2
			if (g!="") {
				printf "group:%s,%s,%s,%s,%s,%s,%s,%s,%s,\n", g, total, ok, fail, ign, other, fail_rate, ignored_rate, severity
			}
			g=""; total=ok=fail=ign=other=fail_rate=ignored_rate=severity=""
		}
	' "$STATS_FILE" >>"$OUT_CSV"
fi

echo "[OK] Build check export CSV generated: $OUT_CSV"
