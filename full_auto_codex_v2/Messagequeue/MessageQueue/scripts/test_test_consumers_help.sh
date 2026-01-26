#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/test_consumers.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

output=$("${SCRIPT}" --help)
if [[ -z "${output}" ]]; then
  echo "Expected help output." >&2
  exit 1
fi
if [[ "${output}" != *"Usage:"* || "${output}" != *"--list"* || "${output}" != *"ROOT_OVERRIDE"* ]]; then
  echo "Help output missing expected content." >&2
  exit 1
fi

echo "[ok] test_consumers help tests passed"
