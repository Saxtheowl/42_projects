#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${OUT:-$ROOT/work/reports_bundle.tar.gz}"
CHECKSUM="${CHECKSUM:-$ROOT/checksums/reports_bundle.sha256}"
INCLUDE_LOGS=1

usage() {
	cat <<EOF
Usage: $0 [--out <file>] [--checksum <file>] [--no-logs]

Archives reports (and logs by default) into a tar.gz with checksum.
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
		--no-logs)
			INCLUDE_LOGS=0
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

if [ -x "$ROOT/scripts/report_index.sh" ]; then
	"$ROOT/scripts/report_index.sh" >/dev/null 2>&1 || true
	INDEX_PATH="$ROOT/reports/index.md"
	if [ -f "$INDEX_PATH" ]; then
		echo "[OK] Index refreshed: $INDEX_PATH"
	fi
fi

if [ "$INCLUDE_LOGS" -eq 1 ]; then
	tar -czf "$OUT" -C "$ROOT" reports logs
else
	tar -czf "$OUT" -C "$ROOT" reports
fi

if command -v sha256sum >/dev/null 2>&1; then
	sha256sum "$OUT" >"$CHECKSUM"
	echo "[OK] Archive created: $OUT"
	echo "[OK] Checksum written: $CHECKSUM"
else
	echo "[WARN] sha256sum not available; skipped checksum." >&2
	echo "[OK] Archive created: $OUT"
fi
