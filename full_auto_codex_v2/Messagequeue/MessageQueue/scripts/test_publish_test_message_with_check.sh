#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/publish_test_message_with_check.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

pdf_dir=$(mktemp -d)
cleanup() {
  rm -rf "${pdf_dir}"
}
trap cleanup EXIT

# Dry-run should succeed without requiring existing PDFs.
raw_output=$(PDF_OUTPUT_DIR="${pdf_dir}" "${SCRIPT}" --dry-run --json)
json_output=$(printf '%s\n' "${raw_output}" | awk '/^{/ { print $0 }' | tail -n 1)
if [[ -z "${json_output}" ]]; then
  echo "Expected JSON output from publish_test_message_with_check." >&2
  exit 1
fi
PDF_DIR="${pdf_dir}" JSON_OUTPUT="${json_output}" python3 - <<'PY'
import json,os,sys
pdf_dir=os.environ["PDF_DIR"]
raw=os.environ.get("JSON_OUTPUT","").strip()
try:
    data=json.loads(raw)
except Exception:
    print("Expected valid JSON output.", file=sys.stderr)
    sys.exit(1)
if data.get("status") not in ("dry_run","warning"):
    print("Expected status dry_run or warning.", file=sys.stderr)
    sys.exit(1)
if data.get("pdf_output_dir") != pdf_dir:
    print("Expected pdf_output_dir to match PDF_OUTPUT_DIR.", file=sys.stderr)
    sys.exit(1)
if data.get("pdf_output_dir_missing") not in ("0","1"):
    print("Expected pdf_output_dir_missing to be 0 or 1.", file=sys.stderr)
    sys.exit(1)
PY

# Ensure PDFs are not required in dry-run mode.
if find "${pdf_dir}" -maxdepth 1 -type f -name '*.pdf' | rg -q .; then
  echo "Expected no PDFs to be created in dry-run." >&2
  exit 1
fi

echo "[ok] publish_test_message_with_check dry-run tests passed"
