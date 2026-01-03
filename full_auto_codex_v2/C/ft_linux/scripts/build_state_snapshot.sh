#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SNAP_DIR="$REPORT_DIR/state_snapshots"
OUT_TXT="$REPORT_DIR/build_state_snapshot.txt"

SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_STATE="$ROOT/work/mini_system.state"
SNAP_ID=""

usage() {
	cat <<EOF
Usage: $0 [--id <id>] [--out <file>]

Snapshot des states build_system/mini_system dans reports/state_snapshots.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--id) SNAP_ID="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$SNAP_DIR"

if [ -z "$SNAP_ID" ]; then
	SNAP_ID="$(date '+%Y%m%d_%H%M%S')"
fi

TARGET_DIR="$SNAP_DIR/$SNAP_ID"
mkdir -p "$TARGET_DIR"

{
	echo "build_state_snapshot generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "snapshot_id: $SNAP_ID"
	echo "snapshot_dir: $TARGET_DIR"
	echo ""
} >"$OUT_TXT"

missing=0

if [ -f "$SYSTEM_STATE" ]; then
	cp "$SYSTEM_STATE" "$TARGET_DIR/build_system.state"
	echo "build_system_state: ok" >>"$OUT_TXT"
else
	echo "build_system_state: missing" >>"$OUT_TXT"
	missing=$((missing + 1))
fi

if [ -f "$MINI_STATE" ]; then
	cp "$MINI_STATE" "$TARGET_DIR/mini_system.state"
	echo "mini_system_state: ok" >>"$OUT_TXT"
else
	echo "mini_system_state: missing" >>"$OUT_TXT"
	missing=$((missing + 1))
fi

if [ "$missing" -eq 2 ]; then
	echo "result: missing" >>"$OUT_TXT"
else
	echo "result: ok" >>"$OUT_TXT"
fi

echo "[OK] Build state snapshot: $OUT_TXT"
