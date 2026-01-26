#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/validate_payload.py"

if [[ ! -f "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$(python3 "${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "--json"; then
  echo "Expected --help to mention --json." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "payload"; then
  echo "Expected --help to mention payload." >&2
  exit 1
fi

echo "[ok] validate_payload help tests passed"
