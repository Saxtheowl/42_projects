#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECKSUMS="$ROOT/docs/checksums.md"
SRC="$ROOT/sources"
OUT="$ROOT/reports/download_missing.sh"

mkdir -p "$(dirname "$OUT")"

cat >"$OUT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="${1:-./sources}"
mkdir -p "$SRC_DIR"

download() {
	local url="$1"
	local out="$SRC_DIR/$(basename "$url")"
	if [ -f "$out" ]; then
		echo "[=] already present: $out"
		return
	fi
	echo "[+] $url"
	curl -L "$url" -o "$out"
}
EOF

while read -r pkg url sha; do
	[ -z "$pkg" ] && continue
	case "$pkg" in
		paquet|---) continue ;;
	esac
	[ -z "$url" ] && continue
	filename="$(basename "$url")"
	if [ ! -f "$SRC/$filename" ]; then
		printf "download '%s'\n" "$url" >>"$OUT"
	fi
done < <(awk -F'|' 'NR>2 && NF>=5 {gsub(/^[ \t]+|[ \t]+$/, "", $2); gsub(/^[ \t]+|[ \t]+$/, "", $4); gsub(/^[ \t]+|[ \t]+$/, "", $5); if($2!="" && $4!="") print $2, $4, $5}' "$CHECKSUMS")

echo "Wrote $OUT"
