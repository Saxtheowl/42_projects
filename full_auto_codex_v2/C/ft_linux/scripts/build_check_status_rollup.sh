#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV_FILE="$REPORT_DIR/build_check_status.csv"
OUT_TXT="$REPORT_DIR/build_check_status_rollup.txt"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>]

Synthese des checks par groupe (dernier statut par paquet).
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
	echo "build_check_status_rollup generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV_FILE" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "missing_csv: $CSV_FILE" >>"$OUT_TXT"
	echo "[OK] Build check status rollup generated: $OUT_TXT"
	exit 0
fi

awk -F'|' '
	NR==1 {next}
	{
		grp=$2; pkg=$3; ts=$1; res=$4; log=$5;
		key=grp "|" pkg
		if (!(key in last_ts) || ts >= last_ts[key]) {
			last_ts[key]=ts; last_res[key]=res; last_log[key]=log;
		}
	}
	END {
		for (key in last_res) {
			split(key, parts, "|");
			grp=parts[1]; pkg=parts[2]; res=last_res[key];
			if (res=="ok") ok[grp]++; else if (res=="fail") fail[grp]++;
			else if (res=="fail_ignored") ign[grp]++; else other[grp]++;
			pkgs[grp]=pkgs[grp] " " pkg;
		}
		n=asorti(pkgs, groups)
		for (i=1; i<=n; i++) {
			grp=groups[i]
			print "[group:" grp "]";
			print "packages: " split(pkgs[grp], dummy, " ") - 1;
			print "ok: " ok[grp]+0;
			print "fail: " fail[grp]+0;
			print "fail_ignored: " ign[grp]+0;
			print "other: " other[grp]+0;
			print "";
			m=0
			for (key in last_res) {
				split(key, parts, "|");
				g=parts[1]; pkg=parts[2];
				if (g!=grp) continue;
				order[++m]=pkg;
			}
			asort(order)
			for (j=1; j<=m; j++) {
				pkg=order[j];
				key=grp "|" pkg;
				res=last_res[key];
				if (res!="ok") {
					printf "package: %s status: %s log: %s\n", pkg, res, last_log[key];
				}
			}
			print "";
			delete order
		}
	}
' "$CSV_FILE" >>"$OUT_TXT"

fail_total=$(grep -E '^fail:' "$OUT_TXT" | awk '{sum+=$2} END {print sum+0}')
if [ "$fail_total" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check status rollup generated: $OUT_TXT"
