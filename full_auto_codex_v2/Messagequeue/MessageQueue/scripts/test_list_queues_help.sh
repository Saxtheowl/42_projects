#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/list_queues.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "QUEUES"; then
  echo "Expected --help to mention QUEUES." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "--json"; then
  echo "Expected --help to mention --json." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "--silent"; then
  echo "Expected --help to mention --silent." >&2
  exit 1
fi

echo "[ok] list_queues help tests passed"
