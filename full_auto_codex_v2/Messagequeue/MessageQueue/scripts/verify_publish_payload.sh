#!/usr/bin/env bash
set -euo pipefail
PAYLOAD=${1:-docs/sample_publish_payload.json}
DIR=${2:-docs}

python3 scripts/check_publish_payload.py --payload "$PAYLOAD" --directory "$DIR" "$([[ ${3:-} == --json ]] && echo --json || true)"
