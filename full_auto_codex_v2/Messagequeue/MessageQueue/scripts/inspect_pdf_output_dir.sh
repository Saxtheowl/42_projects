#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PDF_DIR="${PDF_OUTPUT_DIR:-$ROOT/shared/pdfs}"

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/inspect_pdf_output_dir.sh [--help]

Environment:
  PDF_OUTPUT_DIR  Directory to inspect (default: shared/pdfs)
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
  echo "PDF_OUTPUT_DIR ($PDF_DIR) does not exist."
  exit 1
fi

echo "PDF output dir: $PDF_DIR"
count=$(find "$PDF_DIR" -type f -name '*.pdf' | wc -l)
echo "PDF count: $count"
