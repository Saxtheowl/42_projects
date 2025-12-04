#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources"

if [ ! -d "$SRC" ]; then
	echo "[!] Aucun répertoire sources trouvé à $SRC" >&2
	exit 1
fi

echo "# SHA256 des tarballs présents dans $SRC"
for f in "$SRC"/*; do
	[ -f "$f" ] || continue
	sha256sum "$f"
done
