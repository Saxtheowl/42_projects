#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/configs/build_system_manifest.tsv"
CHECKSUMS="$ROOT/docs/checksums.md"
OUT_TXT="$ROOT/reports/manifest_sources.txt"
OUT_CSV="$ROOT/reports/manifest_sources.csv"

trim() {
	printf '%s' "$1" | xargs
}

mkdir -p "$(dirname "$OUT_TXT")"
echo "package version url sha256" >"$OUT_TXT"
echo "package,version,url,sha256" >"$OUT_CSV"

if [ ! -f "$MANIFEST" ]; then
	echo "[ERR] Missing manifest: $MANIFEST" >&2
	exit 1
fi
if [ ! -f "$CHECKSUMS" ]; then
	echo "[ERR] Missing checksums: $CHECKSUMS" >&2
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
		continue
	fi
	match=$(awk -F'|' -v pkg="$name" -v ver="$version" '
		NR>2 && NF>=5 {
			gsub(/^[ \t]+|[ \t]+$/, "", $2);
			gsub(/^[ \t]+|[ \t]+$/, "", $3);
			gsub(/^[ \t]+|[ \t]+$/, "", $4);
			gsub(/^[ \t]+|[ \t]+$/, "", $5);
			if ($2==pkg && $3==ver) print $4 "|" $5;
		}' "$CHECKSUMS")
	if [ -z "$match" ]; then
		echo "$name $version MISSING_SHA MISSING_SHA" >>"$OUT_TXT"
		echo "$name,$version,missing,missing" >>"$OUT_CSV"
		continue
	fi
	url="${match%|*}"
	sha="${match#*|}"
	echo "$name $version $url $sha" >>"$OUT_TXT"
	echo "$name,$version,$url,$sha" >>"$OUT_CSV"
done <"$MANIFEST"

echo "Wrote $OUT_TXT"
echo "Wrote $OUT_CSV"
