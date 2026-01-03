#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_state_validation.txt"
OUT_CSV="$REPORT_DIR/build_state_validation.csv"

SYSTEM_MANIFEST="$ROOT/configs/build_system_manifest.tsv"
SYSTEM_STATE="$ROOT/work/build_system.state"
MINI_MANIFEST="$ROOT/configs/mini_system_manifest.tsv"
MINI_STATE="$ROOT/work/mini_system.state"
PRUNE=0
TOTAL_UNKNOWN=0
TOTAL_DUP=0

usage() {
	cat <<EOF
Usage: $0 [--prune] [--system-manifest <file>] [--system-state <file>] [--mini-manifest <file>] [--mini-state <file>]

Valide les states de reprise (entrees inconnues/duplications). --prune supprime les entries inconnues.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--prune) PRUNE=1; shift ;;
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
	awk -F'|' 'NF && $1 !~ /^#/ {gsub(/^ +| +$/, "", $1); print $1}' "$manifest" | sort -u
}

state_names() {
	local state="$1"
	if [ -f "$state" ]; then
		sort -u "$state"
	fi
}

validate_pair() {
	local label="$1" manifest="$2" state="$3"
	local unknown_count dup_count total_state
	local tmp_state tmp_manifest tmp_unknown tmp_dups
	tmp_state="$(mktemp)"
	tmp_manifest="$(mktemp)"
	tmp_unknown="$(mktemp)"
	tmp_dups="$(mktemp)"

	manifest_names "$manifest" >"$tmp_manifest"
	if [ -f "$state" ]; then
		sort "$state" >"$tmp_state"
	else
		: >"$tmp_state"
	fi

	total_state=$(wc -l <"$tmp_state" | tr -d ' ')
	uniq -d "$tmp_state" >"$tmp_dups" || true
	comm -23 "$tmp_state" "$tmp_manifest" >"$tmp_unknown" || true

	dup_count=$(wc -l <"$tmp_dups" | tr -d ' ')
	unknown_count=$(wc -l <"$tmp_unknown" | tr -d ' ')
	TOTAL_DUP=$((TOTAL_DUP + dup_count))
	TOTAL_UNKNOWN=$((TOTAL_UNKNOWN + unknown_count))

	{
		echo "[$label]"
		echo "manifest: $manifest"
		echo "state: $state"
		echo "entries: $total_state"
		echo "duplicates: $dup_count"
		echo "unknown: $unknown_count"
		if [ "$dup_count" -gt 0 ]; then
			echo "duplicate_list:"
			cat "$tmp_dups"
		else
			echo "duplicate_list: none"
		fi
		if [ "$unknown_count" -gt 0 ]; then
			echo "unknown_list:"
			cat "$tmp_unknown"
		else
			echo "unknown_list: none"
		fi
		echo ""
	} >>"$OUT_TXT"

	printf '%s,%s,%s,%s,%s\n' "$label" "$manifest" "$total_state" "$dup_count" "$unknown_count" >>"$OUT_CSV"

	if [ "$PRUNE" -eq 1 ] && [ "$unknown_count" -gt 0 ]; then
		comm -12 "$tmp_state" "$tmp_manifest" >"$state"
		echo "[i] prune: $label -> $state" >>"$OUT_TXT"
	fi

	rm -f "$tmp_state" "$tmp_manifest" "$tmp_unknown" "$tmp_dups"
}

{
	echo "build_state_validation generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "prune: $PRUNE"
	echo ""
} >"$OUT_TXT"

echo "label,manifest,entries,duplicates,unknown" >"$OUT_CSV"

validate_pair "build_system" "$SYSTEM_MANIFEST" "$SYSTEM_STATE"
validate_pair "mini_system" "$MINI_MANIFEST" "$MINI_STATE"

if [ "$TOTAL_DUP" -eq 0 ] && [ "$TOTAL_UNKNOWN" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
	echo "total_duplicates: $TOTAL_DUP" >>"$OUT_TXT"
	echo "total_unknown: $TOTAL_UNKNOWN" >>"$OUT_TXT"
fi

echo "[OK] Build state validation generated: $OUT_TXT $OUT_CSV"
