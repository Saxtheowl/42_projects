#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/build_check_regressions_groups.txt"
OUT_JSON="$REPORT_DIR/build_check_regressions_groups.json"
OUT_TXT="$REPORT_DIR/build_check_regressions_groups_json.txt"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--json <file>] [--out <file>]

Exporte un JSON des regressions par groupe.
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
	echo "build_check_regressions_groups_json generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "in: $IN_TXT"
	echo "json: $OUT_JSON"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TXT" ]; then
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$IN_TXT\","
		echo "  \"groups\": [],"
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	echo "result: missing_report" >>"$OUT_TXT"
	echo "missing_report: $IN_TXT" >>"$OUT_TXT"
	echo "[OK] Build check regressions groups JSON generated: $OUT_TXT"
	exit 0
fi

groups=$(
	awk '
		/^\[group:/ {g=$0; sub(/^\[group:/,"",g); sub(/\]$/,"",g)}
		/^total_compared:/ {tc=$2}
		/^regressions:/ {reg=$2}
		/^recoveries:/ {rec=$2}
		/^unchanged:/ {unch=$2}
		/^added:/ {add=$2}
		/^removed:/ {rem=$2}
		/^regression_rate:/ {
			rate=$2
			if (g!="") {
				printf "{\"group\":\"%s\",\"total_compared\":%s,\"regressions\":%s,\"recoveries\":%s,\"unchanged\":%s,\"added\":%s,\"removed\":%s,\"regression_rate\":%s}\n",
					g, tc+0, reg+0, rec+0, unch+0, add+0, rem+0, rate+0;
			}
			g=tc=reg=rec=unch=add=rem=rate=""
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
	echo "  \"groups\": $groups,"
	echo "  \"result\": \"ok\""
	echo "}"
} >"$OUT_JSON"

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build check regressions groups JSON generated: $OUT_TXT"
