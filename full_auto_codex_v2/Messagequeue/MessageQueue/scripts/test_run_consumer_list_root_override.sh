#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_consumer.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

mkdir -p "${stub_dir}/services/consumers/food_application" "${stub_dir}/services/consumers/grant_other_documents"

list_output=$(ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --list)
if [[ -z "${list_output}" ]]; then
  echo "Expected list output." >&2
  exit 1
fi
if ! printf '%s' "${list_output}" | rg -q "food_application"; then
  echo "Expected food_application in list." >&2
  exit 1
fi
if ! printf '%s' "${list_output}" | rg -q "grant_other_documents"; then
  echo "Expected grant_other_documents in list." >&2
  exit 1
fi

echo "[ok] run_consumer list ROOT_OVERRIDE tests passed"
