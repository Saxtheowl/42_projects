#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set +e
output="$(MODULES=", , " "${ROOT_DIR}/scripts/build_modules.sh" --list 2>&1)"
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit for empty MODULES with --list" >&2
  exit 1
fi
if ! echo "${output}" | grep -q "No modules matched"; then
  echo "Expected no modules matched error" >&2
  exit 1
fi

echo "[ok] build_modules list empty MODULES tests passed"
