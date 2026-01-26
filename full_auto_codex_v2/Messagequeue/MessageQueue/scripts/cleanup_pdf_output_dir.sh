#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PDF_DIR="${PDF_OUTPUT_DIR:-$ROOT/shared/pdfs}"

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/cleanup_pdf_output_dir.sh [--help]

Environment:
  PDF_OUTPUT_DIR  Directory to clean (default: shared/pdfs)
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

if [ ! -d "$PDF_DIR" ]; then
  echo "PDF_OUTPUT_DIR ($PDF_DIR) does not exist; nothing to clean."
  exit 0
fi

echo "Cleaning PDF output dir: $PDF_DIR"
rm -f "$PDF_DIR"/*.pdf
echo "Clean completed."
