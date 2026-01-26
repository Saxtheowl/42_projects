#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/inspect_pdf_output_dir.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

pdf_dir=$(mktemp -d)
cleanup() {
  rm -rf "${pdf_dir}"
}
trap cleanup EXIT

missing_dir="${pdf_dir}/missing"
if PDF_OUTPUT_DIR="${missing_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected inspect_pdf_output_dir to fail for missing directory." >&2
  exit 1
fi

mkdir -p "${pdf_dir}/nested"
touch "${pdf_dir}/one.pdf" "${pdf_dir}/nested/two.pdf" "${pdf_dir}/note.txt"

output=$(PDF_OUTPUT_DIR="${pdf_dir}" "${SCRIPT}")
if ! printf '%s' "${output}" | rg -q "PDF output dir"; then
  echo "Expected inspect_pdf_output_dir to print directory path." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "PDF count: 2"; then
  echo "Expected inspect_pdf_output_dir to count PDFs (2)." >&2
  exit 1
fi

echo "[ok] inspect_pdf_output_dir tests passed"
