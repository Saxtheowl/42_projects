#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REG_FILE="$REPORT_DIR/build_check_regressions.txt"
GROUPS_FILE="$REPORT_DIR/build_check_regressions_groups.txt"
TREND_FILE="$REPORT_DIR/build_check_regressions_trend.txt"
OUT_TXT="$REPORT_DIR/build_check_regressions_summary.txt"
OUT_JSON="$REPORT_DIR/build_check_regressions_summary.json"

usage() {
	cat <<EOF
Usage: $0 [--reg <file>] [--groups <file>] [--trend <file>] [--out <file>] [--json <file>]

Synthese des regressions (global + worst group + dernier pair).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--reg) REG_FILE="$2"; shift 2 ;;
		--groups) GROUPS_FILE="$2"; shift 2 ;;
		--trend) TREND_FILE="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_check_regressions_summary generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "reg: $REG_FILE"
	echo "groups: $GROUPS_FILE"
	echo "trend: $TREND_FILE"
	echo "json: $OUT_JSON"
	echo ""
} >"$OUT_TXT"

regressions=$(grep -E '^regressions:' "$REG_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')
recoveries=$(grep -E '^recoveries:' "$REG_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')
total_compared=$(grep -E '^total_compared:' "$REG_FILE" 2>/dev/null | head -n 1 | awk '{print $2}')
regressions=${regressions:-0}
recoveries=${recoveries:-0}
total_compared=${total_compared:-0}

worst_group=""
worst_rate="0"
if [ -f "$GROUPS_FILE" ]; then
	IFS='|' read -r worst_group worst_rate < <(
		awk '
			/^\[group:/ {g=$0; sub(/^\[group:/,"",g); sub(/\]$/,"",g)}
			/^regression_rate:/ {
				r=$2;
				if (g!="") {
					if (r+0 >= max+0) {max=r; mg=g}
				}
				g="";
			}
			END {if (mg!="") printf "%s|%s", mg, max}
		' "$GROUPS_FILE"
	)
fi
worst_rate=${worst_rate:-0}

last_pair=""
last_reg="0"
if [ -f "$TREND_FILE" ]; then
	last_pair=$(awk '/^\[pair:/ {pair=$0} END {print pair}' "$TREND_FILE")
	last_reg=$(awk '
		/^\[pair:/ {in_pair=1}
		/^\[pair:/ {pair=$0}
		/^regressions:/ {reg=$2}
		END {if (pair!="") print reg+0}
	' "$TREND_FILE")
fi
last_reg=${last_reg:-0}

echo "regressions: $regressions" >>"$OUT_TXT"
echo "recoveries: $recoveries" >>"$OUT_TXT"
echo "total_compared: $total_compared" >>"$OUT_TXT"
echo "worst_group: ${worst_group}" >>"$OUT_TXT"
echo "worst_rate: $worst_rate" >>"$OUT_TXT"
echo "last_pair: ${last_pair}" >>"$OUT_TXT"
echo "last_regressions: $last_reg" >>"$OUT_TXT"

result="ok"
if [ "$total_compared" -eq 0 ]; then
	result="partial"
elif [ "$regressions" -gt 0 ]; then
	result="warn"
fi
echo "result: $result" >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"reg\": \"$REG_FILE\","
	echo "  \"groups\": \"$GROUPS_FILE\","
	echo "  \"trend\": \"$TREND_FILE\","
	echo "  \"summary\": {"
	echo "    \"regressions\": $regressions,"
	echo "    \"recoveries\": $recoveries,"
	echo "    \"total_compared\": $total_compared,"
	echo "    \"worst_group\": \"${worst_group}\","
	echo "    \"worst_rate\": ${worst_rate},"
	echo "    \"last_pair\": \"${last_pair}\","
	echo "    \"last_regressions\": ${last_reg}"
	echo "  },"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build check regressions summary generated: $OUT_TXT"
