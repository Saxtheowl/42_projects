#!/usr/bin/env bash
set -euo pipefail

PRODUCER_URL="${PRODUCER_URL:-http://localhost:8080/students}"
PAYLOAD_FILE="${PAYLOAD_FILE:-docs/sample_student.json}"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

if [ ! -f "${PAYLOAD_FILE}" ]; then
  echo "Payload file not found: ${PAYLOAD_FILE}" >&2
  exit 1
fi

curl -fsS -H "Content-Type: application/json" \
  -X POST "${PRODUCER_URL}" \
  --data "@${PAYLOAD_FILE}"

echo
