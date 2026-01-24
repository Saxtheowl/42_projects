#!/usr/bin/env bash
set -euo pipefail

PRODUCER_URL="${PRODUCER_URL:-http://localhost:8080/students}"
PAYLOAD_FILE="${PAYLOAD_FILE:-docs/sample_student.json}"
OUTPUT="${OUTPUT:-raw}"

silent=0
json_output=0
for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/post_sample.sh [--help] [--silent] [--json]

Environment:
  PRODUCER_URL Producer endpoint (default: http://localhost:8080/students)
  PAYLOAD_FILE Payload JSON (default: docs/sample_student.json)
  OUTPUT       raw|pretty|status (default: raw)
EOF
    exit 0
  elif [[ "${arg}" == "--silent" ]]; then
    silent=1
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

if [ ! -f "${PAYLOAD_FILE}" ]; then
  echo "Payload file not found: ${PAYLOAD_FILE}" >&2
  exit 1
fi

response=$(curl -fsS -H "Content-Type: application/json" \
  -X POST "${PRODUCER_URL}" \
  --data "@${PAYLOAD_FILE}")

if [[ "${json_output}" -eq 1 ]]; then
  printf '%s\n' "${response}"
  exit 0
fi

if [[ "${OUTPUT}" == "status" ]]; then
  printf '%s\n' "${response}" | python3 - <<'PY'
import json,sys
try:
  data=json.load(sys.stdin)
  print(data.get("status",""))
except json.JSONDecodeError:
  print("")
PY
  exit 0
fi

if [[ "${silent}" -eq 1 ]]; then
  exit 0
fi

case "${OUTPUT}" in
  raw)
    printf '%s\n' "${response}"
    ;;
  pretty)
    if command -v jq >/dev/null 2>&1; then
      printf '%s\n' "${response}" | jq .
    else
      echo "jq not found; falling back to raw output." >&2
      printf '%s\n' "${response}"
    fi
    ;;
  *)
    echo "Unknown OUTPUT: ${OUTPUT} (use raw or pretty)" >&2
    exit 1
    ;;
esac
