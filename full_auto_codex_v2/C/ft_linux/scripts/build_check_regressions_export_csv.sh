#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/build_check_regressions_groups.txt"
OUT_CSV="$REPORT_DIR/build_check_regressions_export.csv"
OUT_TXT="$REPORT_DIR/build_check_regressions_export.txt"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--out <file>] [--report <file>]

Exporte un CSV des regressions par groupe.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--in) IN_TXT="$2"; shift 2 ;;
		--out) OUT_CSV="$2"; shift 2 ;;
		--report) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_check_regressions_export generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "in: $IN_TXT"
	echo "csv: $OUT_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TXT" ]; then
	echo "result: missing_report" >>"$OUT_TXT"
	echo "missing_report: $IN_TXT" >>"$OUT_TXT"
	echo "[OK] Build check regressions export generated: $OUT_TXT"
	exit 0
fi

echo "group,total_compared,regressions,recoveries,unchanged,added,removed,regression_rate" >"$OUT_CSV"

awk '
	/^\[group:/ {
		g=$0; sub(/^\[group:/,"",g); sub(/\]$/,"",g);
		next
	}
	/^total_compared:/ {tc=$2}
	/^regressions:/ {reg=$2}
	/^recoveries:/ {rec=$2}
	/^unchanged:/ {unch=$2}
	/^added:/ {add=$2}
	/^removed:/ {rem=$2}
	/^regression_rate:/ {
		rate=$2
		if (g!="") {
			printf "%s,%s,%s,%s,%s,%s,%s,%s\n", g, tc+0, reg+0, rec+0, unch+0, add+0, rem+0, rate+0
		}
		g=""; tc=reg=rec=unch=add=rem=rate=""
	}
' "$IN_TXT" >>"$OUT_CSV"

groups=$(tail -n +2 "$OUT_CSV" | wc -l | awk '{print $1}')
echo "groups: ${groups:-0}" >>"$OUT_TXT"

if [ "${groups:-0}" -eq 0 ]; then
	echo "result: warn" >>"$OUT_TXT"
else
	echo "result: ok" >>"$OUT_TXT"
fi

echo "[OK] Build check regressions export generated: $OUT_TXT"
