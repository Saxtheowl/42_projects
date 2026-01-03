#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECKSUMS="$ROOT/docs/checksums.md"
SRC="$ROOT/sources"
OUT_TXT="$ROOT/reports/sha_report.txt"
OUT_CSV="$ROOT/reports/sha_report.csv"

mkdir -p "$(dirname "$OUT_TXT")"

echo "checksum report" >"$OUT_TXT"
echo "generated: $(date '+%Y-%m-%d %H:%M:%S')" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"

echo "package,filename,status" >"$OUT_CSV"

ok_count=0
missing_count=0
sha_missing_count=0
mismatch_count=0

while read -r pkg url sha; do
	[ -z "$pkg" ] && continue
	case "$pkg" in
		paquet|---) continue ;;
	esac
	[ -z "$url" ] && continue
	filename="$(basename "$url")"
	file="$SRC/$filename"
	if [ ! -f "$file" ]; then
		echo "- $pkg $filename: missing" >>"$OUT_TXT"
		echo "$pkg,$filename,missing" >>"$OUT_CSV"
		missing_count=$((missing_count + 1))
		continue
	fi
	if [ -z "$sha" ] || [ "$sha" = "TODO" ]; then
		echo "- $pkg $filename: sha missing" >>"$OUT_TXT"
		echo "$pkg,$filename,sha_missing" >>"$OUT_CSV"
		sha_missing_count=$((sha_missing_count + 1))
		continue
	fi
	got=$(sha256sum "$file" | awk '{print $1}')
	if [ "$got" = "$sha" ]; then
		echo "- $pkg $filename: ok" >>"$OUT_TXT"
		echo "$pkg,$filename,ok" >>"$OUT_CSV"
		ok_count=$((ok_count + 1))
	else
		echo "- $pkg $filename: mismatch" >>"$OUT_TXT"
		echo "  expected: $sha" >>"$OUT_TXT"
		echo "  got:      $got" >>"$OUT_TXT"
		echo "$pkg,$filename,mismatch" >>"$OUT_CSV"
		mismatch_count=$((mismatch_count + 1))
	fi
done < <(awk -F'|' 'NR>2 && NF>=5 {gsub(/^[ \t]+|[ \t]+$/, "", $2); gsub(/^[ \t]+|[ \t]+$/, "", $4); gsub(/^[ \t]+|[ \t]+$/, "", $5); if($2!="" && $4!="") print $2, $4, $5}' "$CHECKSUMS")

{
	echo ""
	echo "summary:"
	echo "- ok: $ok_count"
	echo "- missing: $missing_count"
	echo "- sha_missing: $sha_missing_count"
	echo "- mismatch: $mismatch_count"
} >>"$OUT_TXT"

echo "Wrote $OUT_TXT"
echo "Wrote $OUT_CSV"

if [ "$missing_count" -ne 0 ] || [ "$sha_missing_count" -ne 0 ] || [ "$mismatch_count" -ne 0 ]; then
	exit 1
fi
