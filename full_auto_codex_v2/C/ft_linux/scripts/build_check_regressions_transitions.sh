#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SNAP_DIR="$REPORT_DIR/check_snapshots"
OUT_TXT="$REPORT_DIR/build_check_regressions_transitions.txt"
SNAP_A=""
SNAP_B=""

usage() {
	cat <<EOF
Usage: $0 [--dir <dir>] [--a <file>] [--b <file>] [--out <file>]

Calcule les transitions de statut entre deux snapshots.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
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
	echo "build_check_regressions_transitions generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "dir: $SNAP_DIR"
	echo ""
} >"$OUT_TXT"

if [ -z "$SNAP_A" ] || [ -z "$SNAP_B" ]; then
	if [ ! -d "$SNAP_DIR" ]; then
		echo "result: missing_dir" >>"$OUT_TXT"
		echo "missing_dir: $SNAP_DIR" >>"$OUT_TXT"
		echo "[OK] Build check regressions transitions generated: $OUT_TXT"
		exit 0
	fi
	mapfile -t snaps < <(ls -1 "$SNAP_DIR"/*.csv 2>/dev/null | sort)
	if [ "${#snaps[@]}" -lt 2 ]; then
		echo "result: missing_snapshots" >>"$OUT_TXT"
		echo "snapshots: ${#snaps[@]}" >>"$OUT_TXT"
		echo "[OK] Build check regressions transitions generated: $OUT_TXT"
		exit 0
	fi
	SNAP_A="${snaps[-2]}"
	SNAP_B="${snaps[-1]}"
	echo "auto_pick: yes" >>"$OUT_TXT"
fi

echo "a: $SNAP_A" >>"$OUT_TXT"
echo "b: $SNAP_B" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"

if [ ! -f "$SNAP_A" ] || [ ! -f "$SNAP_B" ]; then
	echo "result: missing_file" >>"$OUT_TXT"
	echo "[OK] Build check regressions transitions generated: $OUT_TXT"
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
			if (k in last_res2) {
				old=last_res1[k]; new=last_res2[k];
				grp=last_grp1[k];
				total++;
				trans[old "->" new]++; trans_g[grp "|" old "->" new]++;
				if (rank(new) > rank(old)) reg++;
				else if (rank(new) < rank(old)) rec++;
			}
		}
		print "transitions_total: " total+0;
		print "regressions: " reg+0;
		print "recoveries: " rec+0;
		print "";
		for (t in trans) {
			printf "transition: %s %d\n", t, trans[t]+0;
		}
		print "";
		for (k in trans_g) {
			split(k, parts, "|");
			grp=parts[1]; t=parts[2];
			if (!(grp in groups)) groups[grp]=1;
		}
		n=asorti(groups, ordered);
		for (i=1; i<=n; i++) {
			grp=ordered[i];
			printf "[group:%s]\n", grp;
			for (t in trans) {
				key=grp "|" t;
				if (key in trans_g) {
					printf "transition: %s %d\n", t, trans_g[key]+0;
				}
			}
			printf "\n";
		}
	}
' "$SNAP_A" "$SNAP_B" >>"$OUT_TXT"

regressions=$(grep -E '^regressions:' "$OUT_TXT" | head -n 1 | awk '{print $2}')
total=$(grep -E '^transitions_total:' "$OUT_TXT" | head -n 1 | awk '{print $2}')

if [ "${total:-0}" -eq 0 ]; then
	echo "result: partial" >>"$OUT_TXT"
elif [ "${regressions:-0}" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check regressions transitions generated: $OUT_TXT"
