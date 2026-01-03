#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="${IMG:-$ROOT/work/disk.raw}"
OUT="${OUT:-$ROOT/work/disk.snapshot.raw}"
CHECKSUM="${CHECKSUM:-$ROOT/checksums/disk.snapshot.sha256}"

usage() {
	cat <<EOF
Usage: $0 [--img <file>] [--out <file>] [--checksum <file>]

Copies the disk image and records a checksum.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--img)
			IMG="${2:-}"
			[ -n "$IMG" ] || usage
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

if [ ! -f "$IMG" ]; then
	echo "[ERR] Image introuvable: $IMG" >&2
	exit 1
fi

mkdir -p "$(dirname "$OUT")" "$(dirname "$CHECKSUM")"

cp -f "$IMG" "$OUT"

if command -v sha256sum >/dev/null 2>&1; then
	sha256sum "$OUT" >"$CHECKSUM"
	echo "[OK] Snapshot created: $OUT"
	echo "[OK] Checksum written: $CHECKSUM"
else
	echo "[WARN] sha256sum not available; skipped checksum." >&2
	echo "[OK] Snapshot created: $OUT"
fi
