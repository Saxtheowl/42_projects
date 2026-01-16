#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/build_check_regressions_groups.txt"
OUT_TXT="$REPORT_DIR/build_check_regressions_top.txt"
OUT_JSON="$REPORT_DIR/build_check_regressions_top.json"
TOP_N=5

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--out <file>] [--json <file>] [--top <n>]

Top regressions par groupe (taux + volume).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--in) IN_TXT="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		--top) TOP_N="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_check_regressions_top generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "in: $IN_TXT"
	echo "json: $OUT_JSON"
	echo "top: $TOP_N"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TXT" ]; then
	echo "result: missing_report" >>"$OUT_TXT"
	echo "missing_report: $IN_TXT" >>"$OUT_TXT"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$IN_TXT\","
		echo "  \"top_n\": $TOP_N,"
		echo "  \"top_by_rate\": [],"
		echo "  \"top_by_count\": [],"
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	echo "[OK] Build check regressions top generated: $OUT_TXT"
	exit 0
fi

awk -v top="$TOP_N" '
	/^\[group:/ {g=$0; sub(/^\[group:/,"",g); sub(/\]$/,"",g)}
	/^total_compared:/ {tc=$2}
	/^regressions:/ {reg=$2}
	/^regression_rate:/ {
		rate=$2
		if (g!="") {
			printf "%s|%s|%s\n", g, rate, reg
		}
		g=""; tc=reg=rate=""
	}
' "$IN_TXT" | sort -t'|' -k2,2nr >"$REPORT_DIR/.regressions_rate.tmp"

top_by_rate=$(
	awk -F'|' -v top="$TOP_N" '
		BEGIN{printf "["; first=1}
		NR<=top{
			g=$1; rate=$2; reg=$3;
			gsub(/"/,"\\\"",g);
			if (!first) printf ",";
			printf "{\"group\":\"%s\",\"rate\":%s,\"regressions\":%s}", g, rate+0, reg+0;
			first=0;
		}
		END{printf "]"}
	' "$REPORT_DIR/.regressions_rate.tmp"
)

awk -v top="$TOP_N" '
	NR==1 {print "top_by_rate:"}
	NR<=top {print "rate: " $0}
' "$REPORT_DIR/.regressions_rate.tmp" >>"$OUT_TXT"

sort -t'|' -k3,3nr "$REPORT_DIR/.regressions_rate.tmp" >"$REPORT_DIR/.regressions_count.tmp"
top_by_count=$(
	awk -F'|' -v top="$TOP_N" '
		BEGIN{printf "["; first=1}
		NR<=top{
			g=$1; rate=$2; reg=$3;
			gsub(/"/,"\\\"",g);
			if (!first) printf ",";
			printf "{\"group\":\"%s\",\"rate\":%s,\"regressions\":%s}", g, rate+0, reg+0;
			first=0;
		}
		END{printf "]"}
	' "$REPORT_DIR/.regressions_count.tmp"
)
awk -v top="$TOP_N" '
	NR==1 {print ""; print "top_by_count:"}
	NR<=top {print "count: " $0}
' "$REPORT_DIR/.regressions_count.tmp" >>"$OUT_TXT"

rm -f "$REPORT_DIR/.regressions_rate.tmp" "$REPORT_DIR/.regressions_count.tmp"

reg_total=$(grep -E '^regressions:' "$IN_TXT" | head -n 1 | awk '{print $2}')
result="ok"
if [ "${reg_total:-0}" -eq 0 ]; then
	echo "" >>"$OUT_TXT"
	echo "result: ok" >>"$OUT_TXT"
else
	echo "" >>"$OUT_TXT"
	echo "result: warn" >>"$OUT_TXT"
	result="warn"
fi

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$IN_TXT\","
	echo "  \"report\": \"$OUT_TXT\","
	echo "  \"top_n\": $TOP_N,"
	echo "  \"top_by_rate\": $top_by_rate,"
	echo "  \"top_by_count\": $top_by_count,"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build check regressions top generated: $OUT_TXT"
