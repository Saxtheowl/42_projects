#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/run_checks.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

output=$(${SCRIPT} --silent --skip-doctor --skip-routing 2>&1)
if echo "${output}" | rg -q "Skipping doctor|Skipping routing matrix|Checks completed"; then
  echo "Expected no skip or completion messages in silent mode" >&2
  exit 1
fi

echo "[ok] run_checks silent skip both no messages tests passed"
