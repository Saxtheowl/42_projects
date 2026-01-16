#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
SNAP_DIR="$REPORT_DIR/state_snapshots"
OUT_TXT="$REPORT_DIR/build_state_diff.txt"

BASE=""
TARGET="current"
SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_STATE="$ROOT/work/mini_system.state"

usage() {
	cat <<EOF
Usage: $0 [--base <id|path>] [--target <id|path|current>] [--out <file>]

Compare deux snapshots (ou snapshot vs etat courant).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--base) BASE="$2"; shift 2 ;;
		--target) TARGET="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

resolve_dir() {
	local value="$1"
	if [ -z "$value" ]; then
		echo ""
		return
	fi
	if [ -d "$value" ]; then
		echo "$value"
	elif [ -d "$SNAP_DIR/$value" ]; then
		echo "$SNAP_DIR/$value"
	else
		echo ""
	fi
}

base_dir="$(resolve_dir "$BASE")"
target_dir=""
if [ "$TARGET" = "current" ]; then
	target_dir="current"
else
	target_dir="$(resolve_dir "$TARGET")"
fi

{
	echo "build_state_diff generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "base: ${BASE:-unset}"
	echo "target: $TARGET"
	echo ""
} >"$OUT_TXT"

if [ -z "$base_dir" ]; then
	echo "result: missing_base" >>"$OUT_TXT"
	echo "[WARN] base snapshot introuvable." >>"$OUT_TXT"
	exit 0
fi

diff_section() {
	local label="$1" base_file="$2" target_file="$3"
	echo "[$label]" >>"$OUT_TXT"
	if [ ! -f "$base_file" ]; then
		echo "base missing: $base_file" >>"$OUT_TXT"
		echo "" >>"$OUT_TXT"
		return
	fi
	if [ ! -f "$target_file" ]; then
		echo "target missing: $target_file" >>"$OUT_TXT"
		echo "" >>"$OUT_TXT"
		return
	fi
	echo "only_in_base:" >>"$OUT_TXT"
	comm -23 <(sort -u "$base_file") <(sort -u "$target_file") >>"$OUT_TXT" || true
	echo "only_in_target:" >>"$OUT_TXT"
	comm -13 <(sort -u "$base_file") <(sort -u "$target_file") >>"$OUT_TXT" || true
	echo "" >>"$OUT_TXT"
}

if [ "$target_dir" = "current" ]; then
	diff_section "build_system" "$base_dir/build_system.state" "$SYSTEM_STATE"
	diff_section "mini_system" "$base_dir/mini_system.state" "$MINI_STATE"
else
	if [ -z "$target_dir" ]; then
		echo "result: missing_target" >>"$OUT_TXT"
		echo "[WARN] target snapshot introuvable." >>"$OUT_TXT"
		exit 0
	fi
	diff_section "build_system" "$base_dir/build_system.state" "$target_dir/build_system.state"
	diff_section "mini_system" "$base_dir/mini_system.state" "$target_dir/mini_system.state"
fi

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Build state diff generated: $OUT_TXT"
