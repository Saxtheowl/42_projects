#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
TARGET="${LFS_TGT:-x86_64-lfs-linux-gnu}"
TOOLS_BIN="$LFS/tools/bin"

fail() {
	printf '[FAIL] %s\n' "$1" >&2
	return 1
}

pass() {
	printf '[OK]   %s\n' "$1"
}

check_file() {
	local path="$1"
	local label="$2"
	if [ -e "$path" ]; then
		pass "$label"
		return 0
	fi
	fail "$label (missing: $path)"
	return 1
}

check_tool() {
	local tool="$1"
	local path="$TOOLS_BIN/$tool"
	check_file "$path" "tool $tool"
}

echo "[1/4] Validate environment"
check_file "$LFS" "LFS root" || true
check_file "$TOOLS_BIN" "tools bin dir" || true

echo "[2/4] Validate cross tools"
check_tool "$TARGET-gcc" || true
check_tool "$TARGET-as" || true
check_tool "$TARGET-ld" || true
check_tool "$TARGET-ar" || true

echo "[3/4] Validate headers"
check_file "$LFS/usr/include/stdio.h" "glibc headers (stdio.h)" || true
check_file "$LFS/usr/include/linux/version.h" "linux headers (version.h)" || true

echo "[4/4] Summary"
if ! check_file "$LFS/tools/lib/gcc/$TARGET" "gcc libgcc directory"; then
	echo "[i] libgcc not installed yet (run build_toolchain.sh libgcc after headers)"
fi

echo "[i] Validation complete."
