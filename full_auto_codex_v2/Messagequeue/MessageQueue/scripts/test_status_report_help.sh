#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/status_report.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "--silent"; then
  echo "Expected --help to mention --silent." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "--json"; then
  echo "Expected --help to mention --json." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "QUEUE_FILTER"; then
  echo "Expected --help to mention QUEUE_FILTER." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "EXCHANGE_FILTER"; then
  echo "Expected --help to mention EXCHANGE_FILTER." >&2
  exit 1
fi

echo "[ok] status_report help tests passed"
