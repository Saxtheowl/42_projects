#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set +e
output="$("${ROOT_DIR}/scripts/build_modules.sh" --list --nope 2>&1)"
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit for unknown option" >&2
  exit 1
fi
if ! echo "${output}" | grep -q "Unknown option"; then
  echo "Expected unknown option error" >&2
  exit 1
fi

echo "[ok] build_modules list unknown option tests passed"
