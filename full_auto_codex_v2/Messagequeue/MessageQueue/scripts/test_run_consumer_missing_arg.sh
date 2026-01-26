#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_consumer.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

output=$("${SCRIPT}" 2>&1 || true)
if [[ -z "${output}" ]]; then
  echo "Expected usage output." >&2
  exit 1
fi
if [[ "${output}" != *"Available consumers"* ]]; then
  echo "Expected Available consumers in output." >&2
  exit 1
fi

echo "[ok] run_consumer missing arg tests passed"
