#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="${IMG:-$ROOT/work/disk.raw}"
OUT="${OUT:-$ROOT/work/disk.qcow2}"
CHECKSUM="${CHECKSUM:-$ROOT/checksums/disk.qcow2.sha256}"

usage() {
	cat <<EOF
Usage: $0 [--img <file>] [--out <file>] [--checksum <file>]

Converts raw disk image to qcow2 and records checksum.
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

command -v qemu-img >/dev/null 2>&1 || {
	echo "[ERR] qemu-img introuvable." >&2
	exit 1
}

if [ ! -f "$IMG" ]; then
	echo "[ERR] Image introuvable: $IMG" >&2
	exit 1
fi

mkdir -p "$(dirname "$OUT")" "$(dirname "$CHECKSUM")"

qemu-img convert -f raw -O qcow2 "$IMG" "$OUT"

if command -v sha256sum >/dev/null 2>&1; then
	sha256sum "$OUT" >"$CHECKSUM"
	echo "[OK] QCOW2 created: $OUT"
	echo "[OK] Checksum written: $CHECKSUM"
else
	echo "[WARN] sha256sum not available; skipped checksum." >&2
	echo "[OK] QCOW2 created: $OUT"
fi
