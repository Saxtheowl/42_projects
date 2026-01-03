#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SNAP_DIR="$REPORT_DIR/check_snapshots"
OUT_TXT="$REPORT_DIR/build_check_snapshot_diff.txt"
SNAP_A=""
SNAP_B=""

usage() {
	cat <<EOF
Usage: $0 [--dir <dir>] [--a <file>] [--b <file>] [--out <file>]

Compare deux snapshots de checks (dernier statut par paquet).
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
	echo "build_check_snapshot_diff generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "dir: $SNAP_DIR"
	echo ""
} >"$OUT_TXT"

if [ -z "$SNAP_A" ] || [ -z "$SNAP_B" ]; then
	if [ ! -d "$SNAP_DIR" ]; then
		echo "result: missing_dir" >>"$OUT_TXT"
		echo "missing_dir: $SNAP_DIR" >>"$OUT_TXT"
		echo "[OK] Build check snapshot diff generated: $OUT_TXT"
		exit 0
	fi
	mapfile -t snaps < <(ls -1 "$SNAP_DIR"/*.csv 2>/dev/null | sort)
	if [ "${#snaps[@]}" -lt 2 ]; then
		echo "result: missing_snapshots" >>"$OUT_TXT"
		echo "snapshots: ${#snaps[@]}" >>"$OUT_TXT"
		echo "[OK] Build check snapshot diff generated: $OUT_TXT"
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
	echo "[OK] Build check snapshot diff generated: $OUT_TXT"
	exit 0
fi

awk -F'|' '
	NR==1 {next}
	FNR==NR {
		key=$2 "|" $3;
		res1[key]=$4;
		next
	}
	NR==1 {next}
	{
		key=$2 "|" $3;
		res2[key]=$4;
	}
	END {
		added=0; removed=0; changed=0;
		for (k in res1) {
			if (!(k in res2)) {
				removed++;
				removed_list[removed]=k "|" res1[k];
			} else if (res1[k] != res2[k]) {
				changed++;
				changed_list[changed]=k "|" res1[k] "|" res2[k];
			}
		}
		for (k in res2) {
			if (!(k in res1)) {
				added++;
				added_list[added]=k "|" res2[k];
			}
		}
		print "added: " added;
		print "removed: " removed;
		print "changed: " changed;
		print "";
		for (i=1; i<=added; i++) {
			print "added: " added_list[i];
		}
		for (i=1; i<=removed; i++) {
			print "removed: " removed_list[i];
		}
		for (i=1; i<=changed; i++) {
			print "changed: " changed_list[i];
		}
	}
' "$SNAP_A" "$SNAP_B" >>"$OUT_TXT"

added=$(grep -E '^added:' "$OUT_TXT" | head -n 1 | awk '{print $2}')
removed=$(grep -E '^removed:' "$OUT_TXT" | head -n 1 | awk '{print $2}')
changed=$(grep -E '^changed:' "$OUT_TXT" | head -n 1 | awk '{print $2}')

if [ "${added:-0}" -eq 0 ] && [ "${removed:-0}" -eq 0 ] && [ "${changed:-0}" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check snapshot diff generated: $OUT_TXT"
