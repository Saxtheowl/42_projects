#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/run_local_flow.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

set +e
output=$("${SCRIPT}" --nope 2>&1)
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit for unknown option" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "Unknown option"; then
  echo "Expected unknown option message" >&2
  exit 1
fi

echo "[ok] run_local_flow unknown option tests passed"
