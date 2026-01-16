#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV_FILE="$REPORT_DIR/build_check_status.csv"
OUT_TXT="$REPORT_DIR/build_check_trend.txt"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>]

Historique des checks par jour (ok/fail/ignored/other).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) CSV_FILE="$2"; shift 2 ;;
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
	echo "build_check_trend generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV_FILE" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "missing_csv: $CSV_FILE" >>"$OUT_TXT"
	echo "[OK] Build check trend generated: $OUT_TXT"
	exit 0
fi

awk -F'|' '
	NR==1 {next}
	{
		day=substr($1,1,10);
		res=$4;
		if (res=="ok") ok[day]++;
		else if (res=="fail") fail[day]++;
		else if (res=="fail_ignored") ign[day]++;
		else other[day]++;
		days[day]=1;
	}
	END {
		n=asorti(days, ordered);
		for (i=1; i<=n; i++) {
			day=ordered[i];
			total=ok[day]+fail[day]+ign[day]+other[day];
			printf "[day:%s]\n", day;
			printf "ok: %d\n", ok[day]+0;
			printf "fail: %d\n", fail[day]+0;
			printf "fail_ignored: %d\n", ign[day]+0;
			printf "other: %d\n", other[day]+0;
			if (total > 0) {
				printf "fail_rate: %.2f\n", (fail[day]+0) * 100 / total;
				printf "ignored_rate: %.2f\n", (ign[day]+0) * 100 / total;
			} else {
				printf "fail_rate: 0.00\n";
				printf "ignored_rate: 0.00\n";
			}
			printf "total: %d\n\n", total;
		}
	}
' "$CSV_FILE" >>"$OUT_TXT"

fail_total=$(grep -E '^fail:' "$OUT_TXT" | awk '{sum+=$2} END {print sum+0}')
if [ "$fail_total" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check trend generated: $OUT_TXT"
