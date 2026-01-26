#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/setup_env.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "SRC"; then
  echo "Expected --help to mention SRC." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "DST"; then
  echo "Expected --help to mention DST." >&2
  exit 1
fi

echo "[ok] setup_env help tests passed"
