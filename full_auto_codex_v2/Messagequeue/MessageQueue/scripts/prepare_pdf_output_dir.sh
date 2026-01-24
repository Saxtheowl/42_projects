#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PDF_DIR="${PDF_OUTPUT_DIR:-$ROOT/shared/pdfs}"

echo "Preparing PDF output directory: $PDF_DIR"
"$ROOT/scripts/verify_pdf_output_dir.sh"
"$ROOT/scripts/cleanup_pdf_output_dir.sh"
echo "PDF output directory prepared."
