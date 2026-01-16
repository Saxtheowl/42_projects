#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_queue_sync.txt"
OUT_CSV="$REPORT_DIR/build_queue_sync.csv"

QUEUE_STATE="$ROOT/work/build_queue.state"
SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_STATE="$ROOT/work/mini_system.state"
APPLY=0

usage() {
	cat <<EOF
Usage: $0 [--queue-state <file>] [--system-state <file>] [--mini-state <file>] [--apply]

Synchronise les states package a partir du build_queue.state.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--queue-state) QUEUE_STATE="$2"; shift 2 ;;
		--system-state) SYSTEM_STATE="$2"; shift 2 ;;
		--mini-state) MINI_STATE="$2"; shift 2 ;;
		--apply) APPLY=1; shift ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR" "$(dirname "$SYSTEM_STATE")" "$(dirname "$MINI_STATE")"

{
	echo "build_queue_sync generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "queue_state: $QUEUE_STATE"
	echo "system_state: $SYSTEM_STATE"
	echo "mini_state: $MINI_STATE"
	echo "apply: $APPLY"
	echo ""
} >"$OUT_TXT"

echo "package,target,action" >"$OUT_CSV"

if [ ! -f "$QUEUE_STATE" ]; then
	echo "result: missing_queue_state" >>"$OUT_TXT"
	echo "[WARN] build_queue.state absent." >>"$OUT_TXT"
	exit 0
fi

added=0
skipped=0
unknown=0

sync_pkg() {
	local pkg="$1" target="$2" state_file="$3"
	if grep -Fxq "$pkg" "$state_file" 2>/dev/null; then
		echo "$pkg,$target,skip" >>"$OUT_CSV"
		skipped=$((skipped + 1))
		return
	fi
	if [ "$APPLY" -eq 1 ]; then
		echo "$pkg" >>"$state_file"
		echo "$pkg,$target,add" >>"$OUT_CSV"
	else
		echo "$pkg,$target,planned" >>"$OUT_CSV"
	fi
	added=$((added + 1))
}

while IFS= read -r line || [ -n "$line" ]; do
	case "$line" in
		""|\#*) continue ;;
	esac
	if printf '%s' "$line" | grep -q "build_system.sh"; then
		pkg=$(printf '%s\n' "$line" | awk -F'pkg' '{print $2}' | sed 's/[\"'\'' ]//g')
		if [ -n "$pkg" ]; then
			sync_pkg "$pkg" "build_system" "$SYSTEM_STATE"
		else
			unknown=$((unknown + 1))
		fi
	elif printf '%s' "$line" | grep -q "build_mini_system.sh"; then
		pkg=$(printf '%s\n' "$line" | awk '{print $NF}' | sed 's/[\"'\'' ]//g')
		if [ -n "$pkg" ]; then
			sync_pkg "$pkg" "mini_system" "$MINI_STATE"
		else
			unknown=$((unknown + 1))
		fi
	else
		unknown=$((unknown + 1))
	fi
done <"$QUEUE_STATE"

echo "added: $added" >>"$OUT_TXT"
echo "skipped: $skipped" >>"$OUT_TXT"
echo "unknown: $unknown" >>"$OUT_TXT"

if [ "$unknown" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build queue sync generated: $OUT_TXT $OUT_CSV"
