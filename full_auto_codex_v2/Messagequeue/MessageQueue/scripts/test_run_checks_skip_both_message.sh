#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/run_checks.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

output=$(${SCRIPT} --skip-doctor --skip-routing 2>&1)
if ! echo "${output}" | rg -q "Skipping doctor"; then
  echo "Expected skip doctor message" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "Skipping routing matrix"; then
  echo "Expected skip routing message" >&2
  exit 1
fi

echo "[ok] run_checks skip both message tests passed"
