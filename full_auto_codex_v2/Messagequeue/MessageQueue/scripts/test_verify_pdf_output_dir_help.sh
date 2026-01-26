#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/verify_pdf_output_dir.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "PDF_OUTPUT_DIR"; then
  echo "Expected --help to mention PDF_OUTPUT_DIR." >&2
  exit 1
fi

echo "[ok] verify_pdf_output_dir help tests passed"
