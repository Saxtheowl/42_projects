#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PAYLOAD="${1:-docs/sample_publish_payload.json}"
PDF_DIR="${PDF_OUTPUT_DIR:-${ROOT_DIR}/shared/pdfs}"
for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/verify_publish_pdf_metadata.sh [payload]

Notes:
  - payload defaults to docs/sample_publish_payload.json
  - uses publish_test_message_with_check.sh --json --dry-run
EOF
      exit 0
      ;;
  esac
done
mkdir -p "${PDF_DIR}"

RAW_OUTPUT=$(
  PDF_OUTPUT_DIR="${PDF_DIR}" \
  PAYLOAD_FILE="${PAYLOAD}" \
  "${ROOT_DIR}/scripts/publish_test_message_with_check.sh" --json --dry-run
)
JSON_OUTPUT=$(printf '%s\n' "${RAW_OUTPUT}" | awk '/^{/ { print $0 }' | tail -n 1)

JSON_OUTPUT="${JSON_OUTPUT}" python3 - <<'PY'
import json,os,sys
data=json.loads(os.environ["JSON_OUTPUT"])
pdf=data.get("pdf_output_dir")
missing=data.get("pdf_output_dir_missing")
if not pdf or missing is None:
    print("Missing pdf_output_dir or pdf_output_dir_missing in JSON", file=sys.stderr)
    sys.exit(1)
print(f"JSON keywords: pdf_output_dir={pdf}, pdf_output_dir_missing={missing}")
if missing != "0":
    print("Expected pdf_output_dir_missing=0; found", missing, file=sys.stderr)
    sys.exit(1)
PY
