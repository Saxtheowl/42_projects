#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/configs/build_system_manifest.tsv"
SRC="$ROOT/sources"

failures=0

trim() {
	printf '%s' "$1" | xargs
}

if [ ! -f "$MANIFEST" ]; then
	echo "[ERR] Manifest missing: $MANIFEST" >&2
	exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
	case "$line" in
		""|\#*) continue ;;
	esac
	IFS='|' read -r raw_name raw_version raw_cfg raw_extra <<<"$line"
	name=$(trim "$raw_name")
	version=$(trim "$raw_version")
	if [ -z "$name" ] || [ -z "$version" ]; then
		echo "[FAIL] Invalid manifest line: $line" >&2
		failures=$((failures + 1))
		continue
	fi
	found=0
	for ext in tar.xz tar.gz tar.bz2 tar.zst; do
		if [ -f "$SRC/$name-$version.$ext" ]; then
			found=1
			break
		fi
	done
	if [ "$found" -eq 0 ]; then
		echo "[WARN] Tarball missing for $name-$version in $SRC" >&2
		failures=$((failures + 1))
	else
		echo "[OK] $name-$version"
	fi
done <"$MANIFEST"

if [ "$failures" -ne 0 ]; then
	echo "[i] Manifest verification completed with $failures issue(s)." >&2
	exit 1
fi
echo "[i] Manifest verification completed."
