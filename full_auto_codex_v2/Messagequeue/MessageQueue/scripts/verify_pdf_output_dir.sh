#!/usr/bin/env bash
set -euo pipefail

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/verify_pdf_output_dir.sh [--help]

Environment:
  PDF_OUTPUT_DIR  Directory to verify/create (required)
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

PDF_OUTPUT_DIR=${PDF_OUTPUT_DIR:-}
if [ -z "$PDF_OUTPUT_DIR" ]; then
  echo "PDF_OUTPUT_DIR is not set" >&2
  exit 1
fi
if [ ! -d "$PDF_OUTPUT_DIR" ]; then
  echo "PDF_OUTPUT_DIR ($PDF_OUTPUT_DIR) does not exist, creating..." >&2
  mkdir -p "$PDF_OUTPUT_DIR"
fi
if [ ! -w "$PDF_OUTPUT_DIR" ]; then
  echo "PDF_OUTPUT_DIR ($PDF_OUTPUT_DIR) is not writable" >&2
  exit 1
fi

echo "PDF output dir verified: $PDF_OUTPUT_DIR"
