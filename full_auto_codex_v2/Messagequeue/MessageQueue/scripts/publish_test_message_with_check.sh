#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
PREPARE_SCRIPT="$ROOT_DIR/scripts/prepare_pdf_output_dir.sh"
ENSURE_SCRIPT="$ROOT_DIR/scripts/ensure_pdf_output_dir_has_file.sh"
for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/publish_test_message_with_check.sh [--help] [publish_test_message options]

Notes:
  - Runs prepare_pdf_output_dir.sh before publishing.
  - Runs ensure_pdf_output_dir_has_file.sh after publish unless --dry-run or SKIP_PDF_CHECK is set.
  - Accepts the same flags as publish_test_message.sh.
EOF
      exit 0
      ;;
  esac
done
if [ ! -x "$PREPARE_SCRIPT" ]; then
  echo "Missing $PREPARE_SCRIPT" >&2
  exit 1
fi
if [ ! -x "$ENSURE_SCRIPT" ]; then
  echo "Missing $ENSURE_SCRIPT" >&2
  exit 1
fi
"$PREPARE_SCRIPT"
"$ROOT_DIR/scripts/publish_test_message.sh" "$@"
DRY_RUN=0
for arg in "$@"; do
  if [[ "${arg}" == "--dry-run" ]]; then
    DRY_RUN=1
    break
  fi
done
if [[ -n "${SKIP_PDF_CHECK:-}" ]]; then
  echo "Skipping ensure_pdf_output_dir_has_file.sh because SKIP_PDF_CHECK is set."
elif [[ $DRY_RUN -eq 0 ]]; then
  "$ENSURE_SCRIPT"
else
  echo "Skipping ensure_pdf_output_dir_has_file.sh for dry-run."
fi
