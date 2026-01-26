#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/prepare_pdf_output_dir.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

base_dir=$(mktemp -d)
cleanup() {
  chmod 700 "${base_dir}" 2>/dev/null || true
  rm -rf "${base_dir}"
}
trap cleanup EXIT

missing_dir="${base_dir}/missing"
# Should create directory and clean PDFs (none exist) without error.
if ! PDF_OUTPUT_DIR="${missing_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected prepare_pdf_output_dir to succeed for missing directory." >&2
  exit 1
fi
if [[ ! -d "${missing_dir}" ]]; then
  echo "Expected prepare_pdf_output_dir to create directory." >&2
  exit 1
fi

# Should remove PDFs unless SKIP_PDF_PREPARE_CLEAN is set.
work_dir="${base_dir}/work"
mkdir -p "${work_dir}"
touch "${work_dir}/a.pdf" "${work_dir}/b.pdf" "${work_dir}/note.txt"
if ! PDF_OUTPUT_DIR="${work_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected prepare_pdf_output_dir to succeed for existing directory." >&2
  exit 1
fi
if ls "${work_dir}"/*.pdf >/dev/null 2>&1; then
  echo "Expected prepare_pdf_output_dir to clean PDFs." >&2
  exit 1
fi
if [[ ! -f "${work_dir}/note.txt" ]]; then
  echo "Expected prepare_pdf_output_dir to keep non-PDF files." >&2
  exit 1
fi

touch "${work_dir}/keep.pdf"
if ! PDF_OUTPUT_DIR="${work_dir}" SKIP_PDF_PREPARE_CLEAN=1 "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected prepare_pdf_output_dir to succeed with SKIP_PDF_PREPARE_CLEAN." >&2
  exit 1
fi
if [[ ! -f "${work_dir}/keep.pdf" ]]; then
  echo "Expected SKIP_PDF_PREPARE_CLEAN to keep PDFs." >&2
  exit 1
fi

# Non-writable dir should fail.
readonly_dir="${base_dir}/readonly"
mkdir -p "${readonly_dir}"
chmod 500 "${readonly_dir}"
if PDF_OUTPUT_DIR="${readonly_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected prepare_pdf_output_dir to fail for non-writable dir." >&2
  exit 1
fi
chmod 700 "${readonly_dir}"

echo "[ok] prepare_pdf_output_dir tests passed"
