#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
SRC="$ROOT/sources"
MANIFEST="$ROOT/configs/build_system_manifest.tsv"
TOOLS="$LFS/tools"
TARGET="${LFS_TGT:-x86_64-lfs-linux-gnu}"

warns=0

warn() {
	printf '[WARN] %s\n' "$1" >&2
	warns=$((warns + 1))
}

ok() {
	printf '[OK]   %s\n' "$1"
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

echo "[1/6] Environment"
check_dir "$LFS" "LFS root"
check_dir "$TOOLS" "LFS tools"
check_dir "$SRC" "sources dir"
check_file "$MANIFEST" "build_system manifest"

echo "[2/6] Toolchain"
check_file "$TOOLS/bin/$TARGET-gcc" "cross gcc"
check_file "$TOOLS/bin/$TARGET-ld" "cross ld"
check_file "$TOOLS/bin/$TARGET-as" "cross as"

echo "[3/6] Toolchain validation"
if [ -x "$ROOT/scripts/validate_toolchain.sh" ]; then
	"$ROOT/scripts/validate_toolchain.sh" || warn "validate_toolchain.sh failed"
else
	warn "validate_toolchain.sh missing"
fi

echo "[4/6] Tarballs"
if [ -f "$ROOT/scripts/verify_manifest.sh" ]; then
	"$ROOT/scripts/verify_manifest.sh" || warn "manifest verification failed"
else
	warn "verify_manifest.sh missing"
fi

echo "[5/6] Disk space"
if command -v df >/dev/null 2>&1; then
	df -h "$LFS" | sed -n '1,2p'
else
	warn "df not available"
fi

echo "[6/6] Host prerequisites"
if [ -x "$ROOT/scripts/check_env_prereqs.sh" ]; then
	"$ROOT/scripts/check_env_prereqs.sh" || warn "check_env_prereqs.sh failed"
else
	warn "check_env_prereqs.sh missing"
fi

if [ "$warns" -ne 0 ]; then
	printf '[i] Preflight completed with %s warning(s).\n' "$warns" >&2
	exit 1
fi
echo "[i] Preflight completed successfully."
