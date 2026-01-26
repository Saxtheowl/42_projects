#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/test_consumers.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

output=$(ROOT_OVERRIDE="/tmp/does-not-exist" "${SCRIPT}" --list 2>&1)
if [[ -z "${output}" ]]; then
  echo "Expected list output" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "food_application"; then
  echo "Expected food_application in list" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "grant_other_documents"; then
  echo "Expected grant_other_documents in list" >&2
  exit 1
fi

echo "[ok] test_consumers list ROOT_OVERRIDE only tests passed"
