#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

output="$(MODULES="producer,contracts" "${ROOT_DIR}/scripts/build_modules.sh" --list 2>&1)"
if ! echo "${output}" | grep -q "services/producer"; then
  echo "Expected producer in list" >&2
  exit 1
fi
if ! echo "${output}" | grep -q "services/consumers/contracts"; then
  echo "Expected contracts in list" >&2
  exit 1
fi
if echo "${output}" | grep -q "financial_assistance"; then
  echo "Unexpected module listed" >&2
  exit 1
fi

echo "[ok] build_modules list filter tests passed"
