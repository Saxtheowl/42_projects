#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SNAP_DIR="$REPORT_DIR/check_snapshots"
OUT_TXT="$REPORT_DIR/build_check_regressions_trend.txt"

usage() {
	cat <<EOF
Usage: $0 [--dir <dir>] [--out <file>]

Historique des regressions/recoveries entre snapshots consecutifs.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--dir) SNAP_DIR="$2"; shift 2 ;;
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
	echo "build_check_regressions_trend generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "dir: $SNAP_DIR"
	echo ""
} >"$OUT_TXT"

if [ ! -d "$SNAP_DIR" ]; then
	echo "result: missing_dir" >>"$OUT_TXT"
	echo "missing_dir: $SNAP_DIR" >>"$OUT_TXT"
	echo "[OK] Build check regressions trend generated: $OUT_TXT"
	exit 0
fi

mapfile -t snaps < <(ls -1 "$SNAP_DIR"/*.csv 2>/dev/null | sort)
if [ "${#snaps[@]}" -lt 2 ]; then
	echo "result: missing_snapshots" >>"$OUT_TXT"
	echo "snapshots: ${#snaps[@]}" >>"$OUT_TXT"
	echo "[OK] Build check regressions trend generated: $OUT_TXT"
	exit 0
fi

echo "pairs: $(( ${#snaps[@]} - 1 ))" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"

for ((i=1; i<${#snaps[@]}; i++)); do
	a="${snaps[i-1]}"
	b="${snaps[i]}"
	base_a="$(basename "$a")"
	base_b="$(basename "$b")"
	echo "[pair:${i}]" >>"$OUT_TXT"
	echo "a: $base_a" >>"$OUT_TXT"
	echo "b: $base_b" >>"$OUT_TXT"
	awk -F'|' '
		function rank(res) {
			if (res=="ok") return 0;
			if (res=="fail_ignored") return 1;
			if (res=="fail") return 2;
			return 3;
		}
		NR==1 {next}
		FNR==NR {
			key=$2 "|" $3; ts=$1; res=$4;
			if (!(key in last_ts1) || ts >= last_ts1[key]) {
				last_ts1[key]=ts; last_res1[key]=res;
			}
			next
		}
		NR==1 {next}
		{
			key=$2 "|" $3; ts=$1; res=$4;
			if (!(key in last_ts2) || ts >= last_ts2[key]) {
				last_ts2[key]=ts; last_res2[key]=res;
			}
		}
		END {
			for (k in last_res1) {
				if (k in last_res2) {
					old=last_res1[k]; new=last_res2[k];
					total++;
					if (rank(new) > rank(old)) reg++;
					else if (rank(new) < rank(old)) rec++;
					else unch++;
				} else {
					removed++;
				}
			}
			for (k in last_res2) {
				if (!(k in last_res1)) added++;
			}
			print "total_compared: " total+0;
			print "regressions: " reg+0;
			print "recoveries: " rec+0;
			print "unchanged: " unch+0;
			print "added: " added+0;
			print "removed: " removed+0;
		}
	' "$a" "$b" >>"$OUT_TXT"
	echo "" >>"$OUT_TXT"
done

reg_total=$(grep -E '^regressions:' "$OUT_TXT" | awk '{sum+=$2} END {print sum+0}')
if [ "${reg_total:-0}" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check regressions trend generated: $OUT_TXT"
