#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV_FILE="$REPORT_DIR/build_check_status.csv"
OUT_TXT="$REPORT_DIR/build_check_status_report.txt"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>]

Synthese du CSV build_check_status (dernier statut par paquet).
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
	echo "build_check_status_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV_FILE" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "missing_csv: $CSV_FILE" >>"$OUT_TXT"
	echo "[OK] Build check status report generated: $OUT_TXT"
	exit 0
fi

awk -F'|' '
	NR==1 {next}
	{
		pkg=$3; ts=$1; res=$4; log=$5;
		if (!(pkg in last_ts) || ts >= last_ts[pkg]) {
			last_ts[pkg]=ts; last_res[pkg]=res; last_log[pkg]=log;
		}
	}
	END {
		ok=0; fail=0; ign=0; other=0;
		for (pkg in last_res) {
			res=last_res[pkg];
			if (res=="ok") ok++;
			else if (res=="fail") fail++;
			else if (res=="fail_ignored") ign++;
			else other++;
		}
		print "packages: " length(last_res);
		print "ok: " ok;
		print "fail: " fail;
		print "fail_ignored: " ign;
		print "other: " other;
		print "";
		n=asorti(last_res, ordered)
		for (i=1; i<=n; i++) {
			pkg=ordered[i]
			printf "package: %s status: %s log: %s\n", pkg, last_res[pkg], last_log[pkg];
		}
	}
' "$CSV_FILE" >>"$OUT_TXT"

fail_count=$(grep -E '^fail:' "$OUT_TXT" | awk '{print $2}')
if [ "${fail_count:-0}" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check status report generated: $OUT_TXT"
