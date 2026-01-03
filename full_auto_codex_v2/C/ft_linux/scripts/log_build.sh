#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_FILE="$ROOT/docs/build_log.md"

usage() {
	echo "Usage: $0 <section> <note>" >&2
	echo "Sections: toolchain|system|kernel|bootloader|network|image" >&2
	exit 1
}

if [ $# -lt 2 ]; then
	usage
fi

section="$1"
shift
note="$*"
timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

case "$section" in
	toolchain) header="## Toolchain" ;;
	system) header="## Système de base (ordre LFS)" ;;
	kernel) header="## Kernel" ;;
	bootloader) header="## Bootloader" ;;
	network) header="## Réseau" ;;
	image) header="## Image finale" ;;
	*) usage ;;
esac

if [ ! -f "$LOG_FILE" ]; then
	echo "[ERR] Missing $LOG_FILE" >&2
	exit 1
fi

awk -v header="$header" -v note="$note" -v ts="$timestamp" '
BEGIN { found=0 }
{
	print $0
	if ($0 == header) {
		print "- [" ts "] " note
		found=1
	}
}
END {
	if (!found) {
		print ""
		print header
		print "- [" ts "] " note
	}
}
' "$LOG_FILE" >"$LOG_FILE.tmp"

mv "$LOG_FILE.tmp" "$LOG_FILE"
echo "Logged to $LOG_FILE"
