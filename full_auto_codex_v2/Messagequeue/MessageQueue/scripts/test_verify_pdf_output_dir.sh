#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/verify_pdf_output_dir.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

base_dir=$(mktemp -d)
missing_dir="${base_dir}/missing"
readonly_dir="${base_dir}/readonly"
mkdir -p "${readonly_dir}"
chmod 500 "${readonly_dir}"

cleanup() {
  chmod 700 "${readonly_dir}" 2>/dev/null || true
  rm -rf "${base_dir}"
}
trap cleanup EXIT

# expect failure when PDF_OUTPUT_DIR is not set
if "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected verify_pdf_output_dir to fail when PDF_OUTPUT_DIR is unset." >&2
  exit 1
fi

# expect to create missing dir
output=$(PDF_OUTPUT_DIR="${missing_dir}" "${SCRIPT}")
if [[ ! -d "${missing_dir}" ]]; then
  echo "Expected verify_pdf_output_dir to create missing directory." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "PDF output dir verified"; then
  echo "Expected success message from verify_pdf_output_dir." >&2
  exit 1
fi

# expect failure on non-writable dir
if PDF_OUTPUT_DIR="${readonly_dir}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected verify_pdf_output_dir to fail on non-writable directory." >&2
  exit 1
fi

chmod 700 "${readonly_dir}"

echo "[ok] verify_pdf_output_dir tests passed"
