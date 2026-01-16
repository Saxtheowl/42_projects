#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
LFS="${LFS:-$ROOT/.lfs}"
RESUME=0
RESET_STATE=0
DRY_RUN=0
SKIP_PREFLIGHT=0

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--resume] [--reset-state] [--dry-run] [--skip-preflight]

Session toolchain: preflight -> build_toolchain -> reports.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs) LFS="$2"; shift 2 ;;
		--resume) RESUME=1; shift ;;
		--reset-state) RESET_STATE=1; shift ;;
		--dry-run) DRY_RUN=1; shift ;;
		--skip-preflight) SKIP_PREFLIGHT=1; shift ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ "$SKIP_PREFLIGHT" -eq 0 ]; then
	"$ROOT/scripts/preflight.sh" --lfs "$LFS" || true
fi

TOOLCHAIN_ARGS=(--lfs "$LFS")
if [ "$RESUME" -eq 1 ]; then
	TOOLCHAIN_ARGS+=(--resume)
fi
if [ "$RESET_STATE" -eq 1 ]; then
	TOOLCHAIN_ARGS+=(--reset-state)
fi
if [ "$DRY_RUN" -eq 1 ]; then
	TOOLCHAIN_ARGS+=(--dry-run)
fi

"$ROOT/scripts/build_toolchain.sh" "${TOOLCHAIN_ARGS[@]}" all

"$ROOT/scripts/build_toolchain_report.sh" || true
"$ROOT/scripts/build_toolchain_report_json.sh" || true
"$ROOT/scripts/build_toolchain_report_validate.sh" || true
"$ROOT/scripts/build_toolchain_session_report.sh" || true
"$ROOT/scripts/build_toolchain_session_report_validate.sh" || true

echo "[OK] Toolchain session completed."
