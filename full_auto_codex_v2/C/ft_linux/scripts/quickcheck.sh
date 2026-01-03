#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[1/4] Toolchain quick validation"
if [ -x "$ROOT/scripts/validate_toolchain.sh" ]; then
	"$ROOT/scripts/validate_toolchain.sh" || true
else
	echo "[WARN] validate_toolchain.sh missing" >&2
fi

echo "[2/4] Manifest verification"
if [ -x "$ROOT/scripts/verify_manifest.sh" ]; then
	"$ROOT/scripts/verify_manifest.sh" || true
else
	echo "[WARN] verify_manifest.sh missing" >&2
fi

echo "[3/4] Build system manifest list"
if [ -x "$ROOT/scripts/build_system.sh" ]; then
	"$ROOT/scripts/build_system.sh" list
else
	echo "[WARN] build_system.sh missing" >&2
fi

echo "[4/4] Reports index"
if [ -x "$ROOT/scripts/report_index.sh" ]; then
	"$ROOT/scripts/report_index.sh"
else
	echo "[WARN] report_index.sh missing" >&2
fi

echo "[i] Quickcheck completed."
