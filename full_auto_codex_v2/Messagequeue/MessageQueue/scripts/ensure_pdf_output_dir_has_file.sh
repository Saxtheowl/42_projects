#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PDF_DIR="${PDF_OUTPUT_DIR:-$ROOT/shared/pdfs}"

if [ ! -d "$PDF_DIR" ]; then
  echo "PDF_OUTPUT_DIR ($PDF_DIR) does not exist."
  exit 1
fi

count=$(find "$PDF_DIR" -maxdepth 1 -type f -name '*.pdf' | wc -l)
echo "PDF count: $count in $PDF_DIR"
if [ "$count" -eq 0 ]; then
  echo "ERROR: No PDF files found in $PDF_DIR" >&2
  exit 1
fi
echo "PDF output directory contains PDF(s)."
