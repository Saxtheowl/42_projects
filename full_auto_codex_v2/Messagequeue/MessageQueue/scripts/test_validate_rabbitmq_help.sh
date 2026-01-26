#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/validate_rabbitmq.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "SOCIAL_EXCHANGE"; then
  echo "Expected --help to mention SOCIAL_EXCHANGE." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "CONTRACTS_ROUTING_KEY"; then
  echo "Expected --help to mention CONTRACTS_ROUTING_KEY." >&2
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

echo "[ok] validate_rabbitmq help tests passed"
