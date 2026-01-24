#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ROUTING_KEYS="${ROUTING_KEYS:-}"
PAYLOAD_FILE="${PAYLOAD_FILE:-}"
STRICT_GRANT_TYPE="${STRICT_GRANT_TYPE:-}"
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/publish_sample_keys.sh [--help] [--silent] [--json]

Environment:
  ROUTING_KEYS     CSV list of keys (default: sample set)
  GRANT_EXCHANGE   Exchange name (default: GRANT_EXCHANGE)
  PAYLOAD_FILE     Payload JSON (default: docs/sample_student.json)
  STRICT_GRANT_TYPE Pass-through to publish_test_message (default: 0)
EOF
    exit 0
  elif [[ "${arg}" == "--silent" ]]; then
    silent=1
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
    silent=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

keys=()
if [[ -n "${ROUTING_KEYS}" ]]; then
  IFS=',' read -r -a raw_keys <<< "${ROUTING_KEYS}"
  for key in "${raw_keys[@]}"; do
    trimmed="$(echo "${key}" | xargs)"
    if [[ -n "${trimmed}" ]]; then
      keys+=("${trimmed}")
    fi
  done
fi

if [ "${#keys[@]}" -eq 0 ]; then
  keys=(
    "grant.application"
    "grant.guarantee"
    "grant.1.contract"
    "grant.2.contract"
  )
fi

"${ROOT}/scripts/check_prereqs.sh" >/dev/null

results=()
for key in "${keys[@]}"; do
  if [[ "${silent}" -eq 0 ]]; then
    echo "Publishing ${key}..."
  fi
  EXCHANGE="${GRANT_EXCHANGE:-GRANT_EXCHANGE}" ROUTING_KEY="${key}" \
    PAYLOAD_FILE="${PAYLOAD_FILE}" STRICT_GRANT_TYPE="${STRICT_GRANT_TYPE}" \
    "${ROOT}/scripts/publish_test_message.sh" --silent >/dev/null
  if [[ "${json_output}" -eq 1 ]]; then
    results+=("${key}")
  fi
  if [[ "${silent}" -eq 0 ]]; then
    echo "OK"
  fi
done

if [[ "${json_output}" -eq 1 ]]; then
  ROUTING_KEYS_JSON="$(printf '%s\n' "${results[@]}")" python3 - <<'PY'
import json,os
keys=[k.strip() for k in os.environ.get("ROUTING_KEYS_JSON","").splitlines() if k.strip()]
print(json.dumps({"status": "ok", "published": keys}))
PY
fi
