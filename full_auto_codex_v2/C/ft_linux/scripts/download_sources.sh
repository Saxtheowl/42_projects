#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources"
CHECKSUMS="$ROOT/docs/checksums.md"
mkdir -p "$SRC"
VERIFY_ONLY=0
LIST_ONLY=0
FROM_DIR=""

usage() {
	echo "Usage: $0 [--verify-only|--list|--from <dir>]" >&2
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
		--verify-only) VERIFY_ONLY=1 ;;
		--list) LIST_ONLY=1 ;;
		--from)
			shift
			[ -n "${1:-}" ] || usage
			FROM_DIR="$1"
			;;
		"" ) ;;
		*) usage ;;
	esac
	shift
done

download() {
	local url="$1"
	local out="$SRC/$(basename "$url")"
	if [ -f "$out" ]; then
		echo "[=] Déjà présent: $out"
	elif [ -n "$FROM_DIR" ] && [ -f "$FROM_DIR/$(basename "$url")" ]; then
		echo "[>] Copie depuis $FROM_DIR"
		cp "$FROM_DIR/$(basename "$url")" "$out"
	else
		echo "[+] Téléchargement $url"
		curl -L "$url" -o "$out"
	fi
}

verify_sha() {
	local file="$1" expected="$2"
	if [ "$expected" = "TODO" ] || [ -z "$expected" ]; then
		echo "[!] SHA manquant pour $(basename "$file"), renseigner docs/checksums.md"
		return
	fi
	local got
	got=$(sha256sum "$file" | awk '{print $1}')
	if [ "$got" != "$expected" ]; then
		echo "[!] SHA mismatch for $file"
		echo "    expected: $expected"
		echo "    got:      $got"
		return 1
	fi
	echo "[OK] $file vérifié"
}

while read -r pkg url sha; do
	[ -z "$pkg" ] && continue
	case "$pkg" in
		paquet|---) continue ;;
	esac
	[ -z "$url" ] && continue
	if [ "$LIST_ONLY" -eq 1 ]; then
		echo "$pkg $url"
		continue
	fi
	if [ "$VERIFY_ONLY" -eq 0 ]; then
		download "$url"
	fi
	verify_sha "$SRC/$(basename "$url")" "$sha"
done < <(awk -F'|' 'NR>2 && NF>=5 {gsub(/^[ \t]+|[ \t]+$/, "", $2); gsub(/^[ \t]+|[ \t]+$/, "", $4); gsub(/^[ \t]+|[ \t]+$/, "", $5); if($2!="" && $4!="") print $2, $4, $5}' "$CHECKSUMS")

if [ "$LIST_ONLY" -eq 1 ]; then
	exit 0
fi
if [ "$VERIFY_ONLY" -eq 1 ]; then
	echo "[i] Vérification terminée. Si des SHA sont 'TODO', remplissez docs/checksums.md puis relancez le script."
else
	echo "[i] Téléchargement terminé. Si des SHA sont 'TODO', remplissez docs/checksums.md puis relancez le script pour vérifier."
fi
