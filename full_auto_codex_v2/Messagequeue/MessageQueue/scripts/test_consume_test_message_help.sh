#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/consume_test_message.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "QUEUE"; then
  echo "Expected --help to mention QUEUE." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "ACK_MODE"; then
  echo "Expected --help to mention ACK_MODE." >&2
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

echo "[ok] consume_test_message help tests passed"
