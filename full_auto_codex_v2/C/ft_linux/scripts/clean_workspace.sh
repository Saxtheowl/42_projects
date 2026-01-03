#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${WORK:-$ROOT/work}"
KEEP_IMAGES=0
DRY_RUN=0

usage() {
	cat <<EOF
Usage: $0 [--work <dir>] [--keep-images] [--dry-run]

Cleans build artifacts under work/ (initramfs, reports bundles, qcow2 snapshot).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--work)
			WORK="${2:-}"
			[ -n "$WORK" ] || usage
			shift 2
			;;
		--keep-images)
			KEEP_IMAGES=1
			shift
			;;
		--dry-run)
			DRY_RUN=1
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

targets=(
	"$WORK/initramfs"
	"$WORK/initramfs.cpio.gz"
	"$WORK/reports_bundle.tar.gz"
	"$WORK/boot_artifacts.tar.gz"
	"$WORK/disk.qcow2"
)

if [ "$KEEP_IMAGES" -eq 0 ]; then
	targets+=("$WORK/disk.snapshot.raw" "$WORK/disk.qcow2")
fi

for t in "${targets[@]}"; do
	if [ -e "$t" ]; then
		if [ "$DRY_RUN" -eq 1 ]; then
			echo "[dry-run] rm -rf $t"
		else
			rm -rf "$t"
			echo "[OK] removed $t"
		fi
	fi
done
