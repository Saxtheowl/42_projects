#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_state_sync.txt"
OUT_CSV="$REPORT_DIR/build_state_sync.csv"

SYSTEM_MANIFEST="$ROOT/configs/build_system_manifest.tsv"
SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_MANIFEST="$ROOT/configs/mini_system_manifest.tsv"
MINI_STATE="$ROOT/work/mini_system.state"
LOGDIR="$ROOT/logs/system"
APPLY=0
RESET=0

usage() {
	cat <<EOF
Usage: $0 [--apply] [--reset] [--logdir <dir>] [--system-manifest <file>] [--system-state <file>] [--mini-manifest <file>] [--mini-state <file>]

Scanne les logs install pour proposer un etat de reprise (option --apply pour ecrire).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--apply) APPLY=1; shift ;;
		--reset) RESET=1; shift ;;
		--logdir) LOGDIR="$2"; shift 2 ;;
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

state_has() {
	local state="$1" name="$2"
	if [ -f "$state" ]; then
		grep -Fxq "$name" "$state"
	else
		return 1
	fi
}

record_state() {
	local state="$1" name="$2"
	mkdir -p "$(dirname "$state")"
	echo "$name" >>"$state"
}

sync_group() {
	local label="$1" manifest="$2" state="$3"
	local name log_path action log_present
	while IFS= read -r name; do
		[ -n "$name" ] || continue
		log_path="$LOGDIR/$name.install.log"
		if [ -s "$log_path" ]; then
			log_present="yes"
			if state_has "$state" "$name"; then
				action="kept"
			else
				action="add"
				if [ "$APPLY" -eq 1 ]; then
					record_state "$state" "$name"
				fi
			fi
		else
			log_present="no"
			action="none"
		fi
		printf '%s | %s | log=%s | action=%s\n' "$label" "$name" "$log_present" "$action" >>"$OUT_TXT"
		printf '%s,%s,%s,%s\n' "$label" "$name" "$log_present" "$action" >>"$OUT_CSV"
	done < <(manifest_names "$manifest")
}

{
	echo "build_state_sync generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "apply: $APPLY"
	echo "reset: $RESET"
	echo "logdir: $LOGDIR"
	echo ""
} >"$OUT_TXT"

echo "group,package,log_present,action" >"$OUT_CSV"

if [ "$RESET" -eq 1 ] && [ "$APPLY" -eq 1 ]; then
	rm -f "$SYSTEM_STATE" "$MINI_STATE"
fi

sync_group "build_system" "$SYSTEM_MANIFEST" "$SYSTEM_STATE"
sync_group "mini_system" "$MINI_MANIFEST" "$MINI_STATE"

echo "[OK] Build state sync generated: $OUT_TXT $OUT_CSV"
