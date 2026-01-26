#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/verify_publish_pdf_metadata.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "docs/sample_publish_payload.json"; then
  echo "Expected --help to mention default payload." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "publish_test_message_with_check"; then
  echo "Expected --help to mention publish_test_message_with_check." >&2
  exit 1
fi

echo "[ok] verify_publish_pdf_metadata help tests passed"
