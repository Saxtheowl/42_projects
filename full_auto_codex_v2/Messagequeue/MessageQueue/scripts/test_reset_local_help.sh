#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/reset_local.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "CLEAN_PDFS"; then
  echo "Expected --help to mention CLEAN_PDFS." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "PURGE_QUEUES"; then
  echo "Expected --help to mention PURGE_QUEUES." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "STOP_DOCKER"; then
  echo "Expected --help to mention STOP_DOCKER." >&2
  exit 1
fi

echo "[ok] reset_local help tests passed"
