#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/ensure_pdf_output_dir_has_file.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "PDF_OUTPUT_DIR"; then
  echo "Expected --help to mention PDF_OUTPUT_DIR." >&2
  exit 1
fi

echo "[ok] ensure_pdf_output_dir_has_file help tests passed"
