#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/run_checks.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

output=$(${SCRIPT} --json --skip-doctor --skip-routing 2>&1)
if ! echo "${output}" | rg -q '"doctor": "skipped"'; then
  echo "Expected doctor skipped in JSON" >&2
  exit 1
fi
if ! echo "${output}" | rg -q '"routing_matrix": "skipped"'; then
  echo "Expected routing_matrix skipped in JSON" >&2
  exit 1
fi
if ! echo "${output}" | rg -q '"status": "ok"'; then
  echo "Expected status ok when all skipped" >&2
  exit 1
fi

echo "[ok] run_checks json skip both tests passed"
