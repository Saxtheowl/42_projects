#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
OUT="${OUT:-$ROOT/work/rootfs.tar.gz}"
CHECKSUM="${CHECKSUM:-$ROOT/checksums/rootfs.sha256}"

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--out <file>] [--checksum <file>]
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
			shift 2
			;;
		--out)
			OUT="${2:-}"
			[ -n "$OUT" ] || usage
			shift 2
			;;
		--checksum)
			CHECKSUM="${2:-}"
			[ -n "$CHECKSUM" ] || usage
			shift 2
			;;
		-h|--help)
			usage
			;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

if [ ! -d "$LFS" ]; then
	echo "[ERR] LFS introuvable: $LFS" >&2
	exit 1
fi

mkdir -p "$(dirname "$OUT")" "$(dirname "$CHECKSUM")"

tar --numeric-owner --xattrs --acls \
	--exclude='./proc' \
	--exclude='./sys' \
	--exclude='./dev' \
	--exclude='./run' \
	-C "$LFS" -czf "$OUT" .

if command -v sha256sum >/dev/null 2>&1; then
	sha256sum "$OUT" >"$CHECKSUM"
	echo "[OK] Rootfs packaged: $OUT"
	echo "[OK] Checksum written: $CHECKSUM"
else
	echo "[WARN] sha256sum not available; skipped checksum." >&2
	echo "[OK] Rootfs packaged: $OUT"
fi
