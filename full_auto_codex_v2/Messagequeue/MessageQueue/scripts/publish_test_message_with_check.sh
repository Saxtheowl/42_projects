#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
VERIFY_SCRIPT="$ROOT_DIR/scripts/verify_pdf_output_dir.sh"
if [ ! -x "$VERIFY_SCRIPT" ]; then
  echo "Missing $VERIFY_SCRIPT" >&2
  exit 1
fi
"$VERIFY_SCRIPT"
"$ROOT_DIR/scripts/publish_test_message.sh" "$@"
