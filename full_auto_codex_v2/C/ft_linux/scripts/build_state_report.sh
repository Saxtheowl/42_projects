#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_state.txt"
OUT_CSV="$REPORT_DIR/build_state.csv"

SYSTEM_MANIFEST="$ROOT/configs/build_system_manifest.tsv"
SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_MANIFEST="$ROOT/configs/mini_system_manifest.tsv"
MINI_STATE="$ROOT/work/mini_system.state"

usage() {
	cat <<EOF
Usage: $0 [--system-manifest <file>] [--system-state <file>] [--mini-manifest <file>] [--mini-state <file>]

Genere un rapport d'etat build (manifest + state de resume).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--system-manifest) SYSTEM_MANIFEST="$2"; shift 2 ;;
		--system-state) SYSTEM_STATE="$2"; shift 2 ;;
		--mini-manifest) MINI_MANIFEST="$2"; shift 2 ;;
		--mini-state) MINI_STATE="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

manifest_names() {
	local manifest="$1"
	awk -F'|' 'NF && $1 !~ /^#/ {gsub(/^ +| +$/, "", $1); print $1}' "$manifest"
}

count_done() {
	local state="$1"
	if [ -f "$state" ]; then
		sort -u "$state" | wc -l | tr -d ' '
	else
		echo 0
	fi
}

pending_list() {
	local manifest="$1" state="$2"
	manifest_names "$manifest" | while IFS= read -r name; do
		if [ -f "$state" ] && grep -Fxq "$name" "$state"; then
			continue
		fi
		echo "$name"
	done
}

emit_report() {
	local label="$1" manifest="$2" state="$3"
	local total done pending_count
	local pending
	total=$(manifest_names "$manifest" | wc -l | tr -d ' ')
	done=$(count_done "$state")
	pending=$(pending_list "$manifest" "$state")
	if [ -n "$pending" ]; then
		pending_count=$(printf '%s\n' "$pending" | wc -l | tr -d ' ')
	else
		pending_count=0
	fi

	{
		echo "[$label]"
		echo "manifest: $manifest"
		echo "state: $state"
		echo "total: $total"
		echo "done: $done"
		echo "pending: $pending_count"
		if [ -n "$pending" ]; then
			echo "pending_list:"
			echo "$pending"
		else
			echo "pending_list: none"
		fi
		echo ""
	} >>"$OUT_TXT"

	printf '%s,%s,%s,%s,%s\n' "$label" "$manifest" "$total" "$done" "$pending_count" >>"$OUT_CSV"
}

{
	echo "build_state_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
} >"$OUT_TXT"

echo "label,manifest,total,done,pending" >"$OUT_CSV"

emit_report "build_system" "$SYSTEM_MANIFEST" "$SYSTEM_STATE"
emit_report "mini_system" "$MINI_MANIFEST" "$MINI_STATE"

echo "[OK] Build state report generated: $OUT_TXT $OUT_CSV"
