#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/ensure_pdf_output_dir_has_file.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

pdf_dir=$(mktemp -d)
cleanup() {
  rm -rf "${pdf_dir}"
}
trap cleanup EXIT

# Missing directory should fail.
missing_dir="${pdf_dir}/missing"
if PDF_OUTPUT_DIR="${missing_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected ensure_pdf_output_dir_has_file to fail for missing directory." >&2
  exit 1
fi

# Empty directory should fail.
if PDF_OUTPUT_DIR="${pdf_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected ensure_pdf_output_dir_has_file to fail for empty directory." >&2
  exit 1
fi

# Directory with a PDF should pass.
touch "${pdf_dir}/demo.pdf"
if ! PDF_OUTPUT_DIR="${pdf_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected ensure_pdf_output_dir_has_file to succeed when a PDF exists." >&2
  exit 1
fi

echo "[ok] ensure_pdf_output_dir_has_file tests passed"
