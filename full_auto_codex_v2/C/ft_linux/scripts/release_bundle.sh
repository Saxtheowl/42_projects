#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${WORK:-$ROOT/work}"
OUT="${OUT:-$ROOT/work/release_bundle.tar.gz}"
CHECKSUM="${CHECKSUM:-$ROOT/checksums/release_bundle.sha256}"
INCLUDE_IMAGES=1

usage() {
	cat <<EOF
Usage: $0 [--out <file>] [--checksum <file>] [--no-images]

Bundles reports, logs, boot artifacts, and optional images into a single tar.gz.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
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
		--no-images)
			INCLUDE_IMAGES=0
			shift
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

mkdir -p "$(dirname "$OUT")" "$(dirname "$CHECKSUM")"
if [ -f "$OUT" ]; then
	rm -f "$OUT"
fi

bundle_paths=(reports logs)
if [ -f "$WORK/boot_artifacts.tar.gz" ]; then
	bundle_paths+=("work/boot_artifacts.tar.gz")
fi
if [ -f "$WORK/reports_bundle.tar.gz" ]; then
	bundle_paths+=("work/reports_bundle.tar.gz")
fi

if [ "$INCLUDE_IMAGES" -eq 1 ]; then
	[ -f "$WORK/disk.raw" ] && bundle_paths+=("work/disk.raw")
	[ -f "$WORK/disk.qcow2" ] && bundle_paths+=("work/disk.qcow2")
	[ -f "$WORK/disk.snapshot.raw" ] && bundle_paths+=("work/disk.snapshot.raw")
fi

tar -czf "$OUT" -C "$ROOT" "${bundle_paths[@]}"

if command -v sha256sum >/dev/null 2>&1; then
	sha256sum "$OUT" >"$CHECKSUM"
	echo "[OK] Release bundle created: $OUT"
	echo "[OK] Checksum written: $CHECKSUM"
else
	echo "[WARN] sha256sum not available; skipped checksum." >&2
	echo "[OK] Release bundle created: $OUT"
fi
