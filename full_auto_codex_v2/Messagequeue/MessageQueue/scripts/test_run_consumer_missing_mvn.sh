#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_consumer.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

output=$(PATH="/bin" "${SCRIPT}" food_application 2>&1 || true)
if [[ "${output}" != *"mvn is required"* ]]; then
  echo "Expected mvn missing error." >&2
  exit 1
fi

echo "[ok] run_consumer missing mvn tests passed"
