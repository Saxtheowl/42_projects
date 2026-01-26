#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/check_prereqs.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

# JSON mode with skips should succeed.
json_output=$(SKIP_DOCKER=1 SKIP_MVN=1 "${SCRIPT}" --json)
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status")=="ok"; assert data.get("missing")==[]'; then
  echo "Expected check_prereqs --json to be ok with SKIP_DOCKER=1 SKIP_MVN=1." >&2
  exit 1
fi

# Ensure skip markers appear in non-silent output.
output=$(SKIP_DOCKER=1 SKIP_MVN=1 "${SCRIPT}")
if ! printf '%s' "${output}" | rg -q "\[skip\] docker"; then
  echo "Expected docker skip marker in check_prereqs output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "\[skip\] mvn"; then
  echo "Expected mvn skip marker in check_prereqs output." >&2
  exit 1
fi

echo "[ok] check_prereqs tests passed"
