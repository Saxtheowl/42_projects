#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PDF_DIR="${PDF_OUTPUT_DIR:-$ROOT/shared/pdfs}"

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/prepare_pdf_output_dir.sh [--help]

Environment:
  PDF_OUTPUT_DIR        Directory to prepare (default: shared/pdfs)
  SKIP_PDF_PREPARE_CLEAN  Skip cleanup step when set
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

echo "Preparing PDF output directory: $PDF_DIR"
"$ROOT/scripts/verify_pdf_output_dir.sh"
if [[ -z "${SKIP_PDF_PREPARE_CLEAN:-}" ]]; then
  "$ROOT/scripts/cleanup_pdf_output_dir.sh"
fi
echo "PDF output directory prepared."
