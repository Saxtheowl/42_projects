#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/verify_publish_pdf_metadata.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

pdf_dir=$(mktemp -d)
invalid_payload=$(mktemp)
cleanup() {
  rm -f "${invalid_payload}"
  rm -rf "${pdf_dir}"
}
trap cleanup EXIT

success_output=$(PDF_OUTPUT_DIR="${pdf_dir}" "${SCRIPT}" "${ROOT_DIR}/docs/sample_publish_payload.json")
if ! printf '%s' "${success_output}" | rg -q "pdf_output_dir="; then
  echo "Expected verify_publish_pdf_metadata to print pdf_output_dir metadata." >&2
  exit 1
fi

printf '%s\n' '{bad json' > "${invalid_payload}"
if PDF_OUTPUT_DIR="${pdf_dir}" "${SCRIPT}" "${invalid_payload}" >/dev/null 2>&1; then
  echo "Expected verify_publish_pdf_metadata to fail on invalid payload." >&2
  exit 1
fi

echo "[ok] verify_publish_pdf_metadata tests passed"
