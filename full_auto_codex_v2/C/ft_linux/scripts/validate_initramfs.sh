#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
MANIFEST="${MANIFEST:-$ROOT/configs/initramfs_manifest.tsv}"
MODULES_LIST="${MODULES_LIST:-$ROOT/configs/initramfs_modules.txt}"
REPORT_DIR="$ROOT/reports"
REPORT_TXT="$REPORT_DIR/initramfs_report.txt"
REPORT_CSV="$REPORT_DIR/initramfs_report.csv"

mkdir -p "$REPORT_DIR"

if [ ! -d "$LFS" ]; then
	echo "[ERR] LFS introuvable: $LFS" >&2
	exit 1
fi
if [ ! -f "$MANIFEST" ]; then
	echo "[ERR] Manifest introuvable: $MANIFEST" >&2
	exit 1
fi

trim() {
	printf '%s' "$1" | xargs
}

missing=0
entries=0

missing_entries=()

while IFS= read -r line || [ -n "$line" ]; do
	case "$line" in
		""|\#*) continue ;;
	esac
	IFS='|' read -r raw_type raw_path raw_target <<<"$line"
	raw_type=$(trim "$raw_type")
	raw_path=$(trim "$raw_path")
	raw_target=$(trim "$raw_target")
	entries=$((entries + 1))
	case "$raw_type" in
		dir)
			if [ ! -d "$LFS/$raw_path" ]; then
				missing_entries+=("$raw_path")
				missing=$((missing + 1))
			fi
			;;
		file)
			if [ ! -f "$LFS/$raw_path" ]; then
				missing_entries+=("$raw_path")
				missing=$((missing + 1))
			fi
			;;
		symlink)
			if [ ! -L "$LFS/$raw_path" ]; then
				missing_entries+=("$raw_path")
				missing=$((missing + 1))
			fi
			;;
		*)
			echo "[ERR] Type inconnu: $raw_type" >&2
			exit 1
			;;
	esac
done <"$MANIFEST"

modules_count=0
if [ -f "$MODULES_LIST" ]; then
	modules_count=$(grep -v '^[[:space:]]*$' "$MODULES_LIST" | wc -l | tr -d ' ')
fi

{
	echo "Initramfs report for $LFS"
	echo "manifest_entries: $entries"
	echo "missing_entries: $missing"
	if [ "$missing" -eq 0 ]; then
		echo "missing_list: none"
	else
		echo "missing_list: ${missing_entries[*]}"
	fi
	if [ -f "$MODULES_LIST" ]; then
		echo "modules_list: $MODULES_LIST"
		echo "modules_count: $modules_count"
	else
		echo "modules_list: missing"
	fi
} >"$REPORT_TXT"

{
	echo "metric,value"
	echo "manifest_entries,$entries"
	echo "missing_entries,$missing"
	echo "missing_list,${missing_entries[*]:-none}"
	echo "modules_list,$( [ -f "$MODULES_LIST" ] && echo "$MODULES_LIST" || echo missing )"
	echo "modules_count,$modules_count"
} >"$REPORT_CSV"

echo "[OK] initramfs report generated: $REPORT_TXT"
