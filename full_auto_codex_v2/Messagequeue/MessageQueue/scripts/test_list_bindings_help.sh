#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/list_bindings.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "ROUTING_KEYS"; then
  echo "Expected --help to mention ROUTING_KEYS." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "SOURCES"; then
  echo "Expected --help to mention SOURCES." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "DESTINATIONS"; then
  echo "Expected --help to mention DESTINATIONS." >&2
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

echo "[ok] list_bindings help tests passed"
