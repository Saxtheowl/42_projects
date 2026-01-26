#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PAYLOAD=${1:-docs/sample_publish_payload.json}
DIR=${2:-docs}

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/verify_publish_payload.sh [payload] [directory] [--json]

Notes:
  - payload defaults to docs/sample_publish_payload.json
  - directory defaults to docs
  - pass --json to emit JSON summary
EOF
      exit 0
      ;;
  esac
done

if [[ "${PAYLOAD}" != /* ]]; then
  PAYLOAD="${ROOT_DIR}/${PAYLOAD}"
fi
if [[ "${DIR}" != /* ]]; then
  DIR="${ROOT_DIR}/${DIR}"
fi

args=(--payload "$PAYLOAD" --directory "$DIR")
if [[ ${3:-} == --json ]]; then
  args+=(--json)
fi

python3 "${ROOT_DIR}/scripts/check_publish_payload.py" "${args[@]}"
