#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
SRC="$ROOT/sources"
MANIFEST="$ROOT/configs/build_system_manifest.tsv"
TOOLS="$LFS/tools"
TARGET="${LFS_TGT:-x86_64-lfs-linux-gnu}"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/preflight.txt"

warns=0

warn() {
	printf '[WARN] %s\n' "$1" >&2
	echo "[WARN] $1" >>"$OUT_TXT"
	warns=$((warns + 1))
}

ok() {
	printf '[OK]   %s\n' "$1"
	echo "[OK]   $1" >>"$OUT_TXT"
}

section() {
	echo "$1"
	echo "$1" >>"$OUT_TXT"
}

check_dir() {
	local path="$1" label="$2"
	if [ -d "$path" ]; then
		ok "$label"
	else
		warn "$label (missing: $path)"
	fi
}

check_file() {
	local path="$1" label="$2"
	if [ -f "$path" ]; then
		ok "$label"
	else
		warn "$label (missing: $path)"
	fi
}

mkdir -p "$REPORT_DIR"
{
	echo "preflight generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "lfs: $LFS"
	echo "tools: $TOOLS"
	echo "sources: $SRC"
	echo "manifest: $MANIFEST"
	echo ""
} >"$OUT_TXT"

section "[1/6] Environment"
check_dir "$LFS" "LFS root"
check_dir "$TOOLS" "LFS tools"
check_dir "$SRC" "sources dir"
check_file "$MANIFEST" "build_system manifest"

section "[2/6] Toolchain"
check_file "$TOOLS/bin/$TARGET-gcc" "cross gcc"
check_file "$TOOLS/bin/$TARGET-ld" "cross ld"
check_file "$TOOLS/bin/$TARGET-as" "cross as"

section "[3/6] Toolchain validation"
if [ -x "$ROOT/scripts/validate_toolchain.sh" ]; then
	"$ROOT/scripts/validate_toolchain.sh" || warn "validate_toolchain.sh failed"
else
	warn "validate_toolchain.sh missing"
fi

section "[4/6] Tarballs"
if [ -f "$ROOT/scripts/verify_manifest.sh" ]; then
	"$ROOT/scripts/verify_manifest.sh" || warn "manifest verification failed"
else
	warn "verify_manifest.sh missing"
fi

section "[5/6] Disk space"
if command -v df >/dev/null 2>&1; then
	df -h "$LFS" | sed -n '1,2p' | tee -a "$OUT_TXT"
else
	warn "df not available"
fi

section "[6/6] Host prerequisites"
if [ -x "$ROOT/scripts/check_env_prereqs.sh" ]; then
	"$ROOT/scripts/check_env_prereqs.sh" || warn "check_env_prereqs.sh failed"
else
	warn "check_env_prereqs.sh missing"
fi

if [ "$warns" -ne 0 ]; then
	printf '[i] Preflight completed with %s warning(s).\n' "$warns" >&2
	echo "" >>"$OUT_TXT"
	echo "warn_count: $warns" >>"$OUT_TXT"
	echo "result: warn" >>"$OUT_TXT"
	exit 1
fi
echo "[i] Preflight completed successfully."
{
	echo ""
	echo "warn_count: 0"
	echo "result: ok"
} >>"$OUT_TXT"
