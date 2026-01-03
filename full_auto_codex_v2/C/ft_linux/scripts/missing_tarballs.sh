#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources"
CHECKSUMS="$ROOT/docs/checksums.md"
OUT_TXT="$ROOT/reports/missing_tarballs.txt"
OUT_CSV="$ROOT/reports/missing_tarballs.csv"

mkdir -p "$(dirname "$OUT_TXT")"

{
	echo "missing tarballs"
	echo "generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
} >"$OUT_TXT"

echo "package,version,url" >"$OUT_CSV"

missing=0
while read -r pkg url sha; do
	[ -z "$pkg" ] && continue
	case "$pkg" in
		paquet|---) continue ;;
	esac
	[ -z "$url" ] && continue
	filename="$(basename "$url")"
	if [ ! -f "$SRC/$filename" ]; then
		printf "%s\n" "- $pkg $filename ($url)" >>"$OUT_TXT"
		printf "%s,%s,%s\n" "$pkg" "$filename" "$url" >>"$OUT_CSV"
		missing=$((missing + 1))
	fi
done < <(awk -F'|' 'NR>2 && NF>=5 {gsub(/^[ \t]+|[ \t]+$/, "", $2); gsub(/^[ \t]+|[ \t]+$/, "", $4); gsub(/^[ \t]+|[ \t]+$/, "", $5); if($2!="" && $4!="") print $2, $4, $5}' "$CHECKSUMS")

if [ "$missing" -eq 0 ]; then
	echo "- none" >>"$OUT_TXT"
fi

echo "Wrote $OUT_TXT"
echo "Wrote $OUT_CSV"
