#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SNAP_DIR="$REPORT_DIR/state_snapshots"
OUT_TXT="$REPORT_DIR/build_state_prune.txt"
KEEP=5
DRY_RUN=0

usage() {
	cat <<EOF
Usage: $0 [--dir <snapshots_dir>] [--keep <n>] [--dry-run]

Supprime les anciens snapshots en gardant les plus recents.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--dir) SNAP_DIR="$2"; shift 2 ;;
		--keep) KEEP="$2"; shift 2 ;;
		--dry-run) DRY_RUN=1; shift ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_state_prune generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "dir: $SNAP_DIR"
	echo "keep: $KEEP"
	echo "dry_run: $DRY_RUN"
	echo ""
} >"$OUT_TXT"

if [ ! -d "$SNAP_DIR" ]; then
	echo "result: missing_dir" >>"$OUT_TXT"
	echo "missing snapshots dir" >>"$OUT_TXT"
	exit 0
fi

list=$(ls -1 "$SNAP_DIR" 2>/dev/null | sort)
count=$(printf '%s\n' "$list" | wc -l | tr -d ' ')
if [ "$count" -le "$KEEP" ]; then
	echo "result: ok" >>"$OUT_TXT"
	echo "nothing to prune" >>"$OUT_TXT"
	exit 0
fi

to_delete=$(printf '%s\n' "$list" | head -n $((count - KEEP)))
echo "deleted:" >>"$OUT_TXT"
for snap in $to_delete; do
	if [ "$DRY_RUN" -eq 1 ]; then
		echo "- $snap (dry-run)" >>"$OUT_TXT"
	else
		rm -rf "$SNAP_DIR/$snap"
		echo "- $snap" >>"$OUT_TXT"
	fi
done

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build state prune completed: $OUT_TXT"
