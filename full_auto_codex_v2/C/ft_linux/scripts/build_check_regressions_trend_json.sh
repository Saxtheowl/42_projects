#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/build_check_regressions_trend.txt"
OUT_JSON="$REPORT_DIR/build_check_regressions_trend.json"
OUT_TXT="$REPORT_DIR/build_check_regressions_trend_json.txt"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--json <file>] [--out <file>]

Exporte un JSON pour le trend des regressions.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--in) IN_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
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
	echo "build_check_regressions_trend_json generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "in: $IN_TXT"
	echo "json: $OUT_JSON"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TXT" ]; then
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$IN_TXT\","
		echo "  \"pairs\": [],"
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	echo "result: missing_report" >>"$OUT_TXT"
	echo "missing_report: $IN_TXT" >>"$OUT_TXT"
	echo "[OK] Build check regressions trend JSON generated: $OUT_TXT"
	exit 0
fi

pairs=$(
	awk '
		/^\[pair:/ {pair=$0; sub(/^\[pair:|]$/, "", pair)}
		/^a:/ {a=$2}
		/^b:/ {b=$2}
		/^total_compared:/ {tc=$2}
		/^regressions:/ {reg=$2}
		/^recoveries:/ {rec=$2}
		/^unchanged:/ {unch=$2}
		/^added:/ {add=$2}
		/^removed:/ {
			rem=$2;
			if (pair!="") {
				printf "{\"pair\":%s,\"a\":\"%s\",\"b\":\"%s\",\"total_compared\":%s,\"regressions\":%s,\"recoveries\":%s,\"unchanged\":%s,\"added\":%s,\"removed\":%s}\n",
					pair+0, a, b, tc+0, reg+0, rec+0, unch+0, add+0, rem+0;
			}
			pair=a=b=tc=reg=rec=unch=add=rem="";
		}
	' "$IN_TXT" | awk '
		BEGIN{printf "["; first=1}
		{if (!first) printf ","; printf "%s", $0; first=0}
		END{printf "]"}
	'
)

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$IN_TXT\","
	echo "  \"pairs\": $pairs,"
	echo "  \"result\": \"ok\""
	echo "}"
} >"$OUT_JSON"

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build check regressions trend JSON generated: $OUT_TXT"
