#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/publish_test_message_with_check.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "prepare_pdf_output_dir"; then
  echo "Expected --help to mention prepare_pdf_output_dir." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "SKIP_PDF_CHECK"; then
  echo "Expected --help to mention SKIP_PDF_CHECK." >&2
  exit 1
fi

echo "[ok] publish_test_message_with_check help tests passed"
