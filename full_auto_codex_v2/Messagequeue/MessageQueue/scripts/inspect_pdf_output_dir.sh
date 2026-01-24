#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PDF_DIR="${PDF_OUTPUT_DIR:-$ROOT/shared/pdfs}"

if [ ! -d "$PDF_DIR" ]; then
  echo "PDF_OUTPUT_DIR ($PDF_DIR) does not exist."
  exit 1
fi

echo "PDF output dir: $PDF_DIR"
count=$(find "$PDF_DIR" -type f -name '*.pdf' | wc -l)
echo "PDF count: $count"
