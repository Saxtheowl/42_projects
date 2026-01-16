#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV_FILE="$REPORT_DIR/build_check_status.csv"
SNAP_DIR="$REPORT_DIR/check_snapshots"
OUT_TXT="$REPORT_DIR/build_check_regressions_groups.txt"
SNAP_A=""
SNAP_B=""

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--dir <dir>] [--a <file>] [--b <file>] [--out <file>]

Regressions/recoveries par groupe (snapshots ou CSV).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) CSV_FILE="$2"; shift 2 ;;
		--dir) SNAP_DIR="$2"; shift 2 ;;
		--a) SNAP_A="$2"; shift 2 ;;
		--b) SNAP_B="$2"; shift 2 ;;
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
	echo "build_check_regressions_groups generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo "dir: $SNAP_DIR"
	echo ""
} >"$OUT_TXT"

use_snapshots=0
auto_pick="no"

if [ -n "$SNAP_A" ] || [ -n "$SNAP_B" ]; then
	use_snapshots=1
	if [ -z "$SNAP_A" ] || [ -z "$SNAP_B" ]; then
		auto_pick="yes"
	fi
else
	if [ -d "$SNAP_DIR" ]; then
		mapfile -t snaps < <(ls -1 "$SNAP_DIR"/*.csv 2>/dev/null | sort)
		if [ "${#snaps[@]}" -ge 2 ]; then
			SNAP_A="${snaps[-2]}"
			SNAP_B="${snaps[-1]}"
			use_snapshots=1
			auto_pick="yes"
		fi
	fi
fi

if [ "$use_snapshots" -eq 1 ] && { [ -z "$SNAP_A" ] || [ -z "$SNAP_B" ]; }; then
	mapfile -t snaps < <(ls -1 "$SNAP_DIR"/*.csv 2>/dev/null | sort)
	if [ "${#snaps[@]}" -ge 2 ]; then
		SNAP_A="${snaps[-2]}"
		SNAP_B="${snaps[-1]}"
		auto_pick="yes"
	else
		use_snapshots=0
	fi
fi

if [ "$use_snapshots" -eq 1 ]; then
	echo "mode: snapshot" >>"$OUT_TXT"
	echo "a: $SNAP_A" >>"$OUT_TXT"
	echo "b: $SNAP_B" >>"$OUT_TXT"
	echo "auto_pick: $auto_pick" >>"$OUT_TXT"
	echo "" >>"$OUT_TXT"

	if [ ! -f "$SNAP_A" ] || [ ! -f "$SNAP_B" ]; then
		echo "result: missing_file" >>"$OUT_TXT"
		echo "[OK] Build check regressions groups generated: $OUT_TXT"
		exit 0
	fi

	awk -F'|' '
		function rank(res) {
			if (res=="ok") return 0;
			if (res=="fail_ignored") return 1;
			if (res=="fail") return 2;
			return 3;
		}
		NR==1 {next}
		FNR==NR {
			key=$2 "|" $3; ts=$1; res=$4; grp=$2;
			if (!(key in last_ts1) || ts >= last_ts1[key]) {
				last_ts1[key]=ts; last_res1[key]=res; last_grp1[key]=grp;
			}
			next
		}
		NR==1 {next}
		{
			key=$2 "|" $3; ts=$1; res=$4; grp=$2;
			if (!(key in last_ts2) || ts >= last_ts2[key]) {
				last_ts2[key]=ts; last_res2[key]=res; last_grp2[key]=grp;
			}
		}
		END {
			for (k in last_res1) {
				grp=last_grp1[k];
				if (k in last_res2) {
					old=last_res1[k]; new=last_res2[k];
					total++;
					total_g[grp]++;
					if (rank(new) > rank(old)) {reg++; reg_g[grp]++;}
					else if (rank(new) < rank(old)) {rec++; rec_g[grp]++;}
					else {unch++; unch_g[grp]++;}
				} else {
					removed++; rem_g[grp]++;
				}
				groups[grp]=1;
			}
			for (k in last_res2) {
				grp=last_grp2[k];
				if (!(k in last_res1)) {
					added++; add_g[grp]++;
				}
				groups[grp]=1;
			}
			print "total_compared: " total+0;
			print "regressions: " reg+0;
			print "recoveries: " rec+0;
			print "unchanged: " unch+0;
			print "added: " added+0;
			print "removed: " removed+0;
			print "";
			n=asorti(groups, ordered);
			for (i=1; i<=n; i++) {
				grp=ordered[i];
				tc=total_g[grp]+0;
				rr=reg_g[grp]+0;
				rc=rec_g[grp]+0;
				uc=unch_g[grp]+0;
				ad=add_g[grp]+0;
				rm=rem_g[grp]+0;
				printf "[group:%s]\n", grp;
				printf "total_compared: %d\n", tc;
				printf "regressions: %d\n", rr;
				printf "recoveries: %d\n", rc;
				printf "unchanged: %d\n", uc;
				printf "added: %d\n", ad;
				printf "removed: %d\n", rm;
				if (tc>0) {
					printf "regression_rate: %.2f\n", (rr*100)/tc;
				} else {
					printf "regression_rate: 0.00\n";
				}
				printf "\n";
			}
		}
	' "$SNAP_A" "$SNAP_B" >>"$OUT_TXT"
else
	echo "mode: csv" >>"$OUT_TXT"
	echo "" >>"$OUT_TXT"

	if [ ! -f "$CSV_FILE" ]; then
		echo "result: missing_csv" >>"$OUT_TXT"
		echo "missing_csv: $CSV_FILE" >>"$OUT_TXT"
		echo "[OK] Build check regressions groups generated: $OUT_TXT"
		exit 0
	fi

	awk -F'|' '
		function rank(res) {
			if (res=="ok") return 0;
			if (res=="fail_ignored") return 1;
			if (res=="fail") return 2;
			return 3;
		}
		NR==1 {next}
		{
			key=$2 "|" $3; ts=$1; res=$4; grp=$2;
			if (!(key in last_ts) || ts >= last_ts[key]) {
				prev_ts[key]=last_ts[key]; prev_res[key]=last_res[key]; prev_grp[key]=last_grp[key];
				last_ts[key]=ts; last_res[key]=res; last_grp[key]=grp;
			} else if (!(key in prev_ts) || ts >= prev_ts[key]) {
				prev_ts[key]=ts; prev_res[key]=res; prev_grp[key]=grp;
			}
		}
		END {
			for (k in last_res) {
				grp=last_grp[k];
				groups[grp]=1;
				if (prev_res[k] != "") {
					old=prev_res[k]; new=last_res[k];
					total++;
					total_g[grp]++;
					if (rank(new) > rank(old)) {reg++; reg_g[grp]++;}
					else if (rank(new) < rank(old)) {rec++; rec_g[grp]++;}
					else {unch++; unch_g[grp]++;}
				} else {
					no_prev++; nop_g[grp]++;
				}
			}
			print "total_compared: " total+0;
			print "regressions: " reg+0;
			print "recoveries: " rec+0;
			print "unchanged: " unch+0;
			print "added: 0";
			print "removed: 0";
			print "";
			n=asorti(groups, ordered);
			for (i=1; i<=n; i++) {
				grp=ordered[i];
				tc=total_g[grp]+0;
				rr=reg_g[grp]+0;
				rc=rec_g[grp]+0;
				uc=unch_g[grp]+0;
				np=nop_g[grp]+0;
				printf "[group:%s]\n", grp;
				printf "total_compared: %d\n", tc;
				printf "regressions: %d\n", rr;
				printf "recoveries: %d\n", rc;
				printf "unchanged: %d\n", uc;
				printf "no_previous: %d\n", np;
				if (tc>0) {
					printf "regression_rate: %.2f\n", (rr*100)/tc;
				} else {
					printf "regression_rate: 0.00\n";
				}
				printf "\n";
			}
		}
	' "$CSV_FILE" >>"$OUT_TXT"
fi

regressions=$(grep -E '^regressions:' "$OUT_TXT" | head -n 1 | awk '{print $2}')
total_compared=$(grep -E '^total_compared:' "$OUT_TXT" | head -n 1 | awk '{print $2}')

if [ "${total_compared:-0}" -eq 0 ]; then
	echo "result: partial" >>"$OUT_TXT"
elif [ "${regressions:-0}" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check regressions groups generated: $OUT_TXT"
