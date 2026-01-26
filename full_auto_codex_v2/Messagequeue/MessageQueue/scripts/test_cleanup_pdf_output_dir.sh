#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/cleanup_pdf_output_dir.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

pdf_dir=$(mktemp -d)
cleanup() {
  rm -rf "${pdf_dir}"
}
trap cleanup EXIT

# Missing directory should be a no-op success.
missing_dir="${pdf_dir}/missing"
if ! PDF_OUTPUT_DIR="${missing_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected cleanup_pdf_output_dir to succeed for missing directory." >&2
  exit 1
fi

# Create files and ensure only PDFs are removed.
mkdir -p "${pdf_dir}/data"
PDF_OUTPUT_DIR="${pdf_dir}" touch "${pdf_dir}/one.pdf" "${pdf_dir}/two.pdf" "${pdf_dir}/note.txt"
if ! PDF_OUTPUT_DIR="${pdf_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected cleanup_pdf_output_dir to succeed for existing directory." >&2
  exit 1
fi
if ls "${pdf_dir}"/*.pdf >/dev/null 2>&1; then
  echo "Expected cleanup_pdf_output_dir to remove PDF files." >&2
  exit 1
fi
if [[ ! -f "${pdf_dir}/note.txt" ]]; then
  echo "Expected cleanup_pdf_output_dir to keep non-PDF files." >&2
  exit 1
fi

# Ensure nested directories are untouched.
if [[ ! -d "${pdf_dir}/data" ]]; then
  echo "Expected cleanup_pdf_output_dir to keep subdirectories." >&2
  exit 1
fi

echo "[ok] cleanup_pdf_output_dir tests passed"
