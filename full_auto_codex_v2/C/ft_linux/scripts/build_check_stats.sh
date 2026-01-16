#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV_FILE="$REPORT_DIR/build_check_status.csv"
OUT_TXT="$REPORT_DIR/build_check_stats.txt"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>]

Statistiques des checks par groupe (dernier statut par paquet).
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
	echo "build_check_stats generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV_FILE" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "missing_csv: $CSV_FILE" >>"$OUT_TXT"
	echo "[OK] Build check stats generated: $OUT_TXT"
	exit 0
fi

awk -F'|' '
	NR==1 {next}
	{
		grp=$2; pkg=$3; ts=$1; res=$4;
		key=grp "|" pkg
		if (!(key in last_ts) || ts >= last_ts[key]) {
			last_ts[key]=ts; last_res[key]=res; last_grp[key]=grp;
		}
	}
	END {
		for (key in last_res) {
			res=last_res[key];
			grp=last_grp[key];
			if (res=="ok") ok[grp]++; else if (res=="fail") fail[grp]++;
			else if (res=="fail_ignored") ign[grp]++; else other[grp]++;
			total[grp]++;
			if (res=="ok") ok_all++; else if (res=="fail") fail_all++;
			else if (res=="fail_ignored") ign_all++; else other_all++;
			total_all++;
			groups[grp]=1;
		}
		n=asorti(groups, ordered);
		printf "total_packages: %d\n", total_all+0;
		printf "ok: %d\n", ok_all+0;
		printf "fail: %d\n", fail_all+0;
		printf "fail_ignored: %d\n", ign_all+0;
		printf "other: %d\n", other_all+0;
		if (total_all>0) {
			printf "fail_rate: %.2f\n", (fail_all+0) * 100 / total_all;
			printf "ignored_rate: %.2f\n", (ign_all+0) * 100 / total_all;
		} else {
			printf "fail_rate: 0.00\n";
			printf "ignored_rate: 0.00\n";
		}
		printf "\n";
		if (total_all>0) {
			fail_rate=(fail_all+0)*100/total_all;
			ignored_rate=(ign_all+0)*100/total_all;
		} else {
			fail_rate=0; ignored_rate=0;
		}
		for (i=1; i<=n; i++) {
			grp=ordered[i];
			printf "[group:%s]\n", grp;
			printf "packages: %d\n", total[grp]+0;
			printf "ok: %d\n", ok[grp]+0;
			printf "fail: %d\n", fail[grp]+0;
			printf "fail_ignored: %d\n", ign[grp]+0;
			printf "other: %d\n", other[grp]+0;
			if (total[grp]>0) {
				gr_fail_rate=(fail[grp]+0)*100/total[grp];
				gr_ignored_rate=(ign[grp]+0)*100/total[grp];
			} else {
				gr_fail_rate=0; gr_ignored_rate=0;
			}
			printf "fail_rate: %.2f\n", gr_fail_rate;
			printf "ignored_rate: %.2f\n", gr_ignored_rate;
			printf "severity: %.2f\n", gr_fail_rate + (gr_ignored_rate/2);
			printf "\n";
		}
		printf "overall_severity: %.2f\n", fail_rate + (ignored_rate/2);
	}
' "$CSV_FILE" >>"$OUT_TXT"

fail_total=$(grep -E '^fail:' "$OUT_TXT" | head -n 1 | awk '{print $2}')
if [ "${fail_total:-0}" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check stats generated: $OUT_TXT"
