#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/doctor.sh [--help] [--silent] [--json]

Options:
  --silent  Suppress output (errors still shown).
  --json    Output JSON summary.
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

if [[ "${json_output}" -eq 1 ]]; then
  prereqs_json=$("${ROOT}/scripts/check_prereqs.sh" --json || true)
  json_status_code=$'import json,sys\nraw=sys.stdin.read().strip()\ntry:\n    data=json.loads(raw) if raw else {}\nexcept json.JSONDecodeError:\n    data={}\nprint(data.get(\"status\",\"error\"))'
  prereqs_status=$(printf '%s' "${prereqs_json}" | python3 -c "${json_status_code}")
else
  "${ROOT}/scripts/check_prereqs.sh"
fi

if [ -f "${ROOT}/.env" ]; then
  "${ROOT}/scripts/load_env.sh" >/dev/null
fi

if [[ "${json_output}" -eq 1 ]]; then
  failed=0
  rabbitmq_json=$("${ROOT}/scripts/check_rabbitmq.sh" --json || true)
  rabbitmq_status=$(printf '%s' "${rabbitmq_json}" | python3 -c "${json_status_code}")
  topology_status="skipped"
  if [[ "${rabbitmq_status}" == "ok" ]]; then
    topology_json=$("${ROOT}/scripts/validate_rabbitmq.sh" --json || true)
    topology_status=$(printf '%s' "${topology_json}" | python3 -c "${json_status_code}")
  fi

  payload_status="ok"
  if ! "${ROOT}/scripts/validate_payload.py" >/dev/null 2>&1; then
    payload_status="error"
    failed=1
  fi
  payload_tests_status="skipped"
  if [ -x "${ROOT}/scripts/test_validate_payload.sh" ]; then
    if "${ROOT}/scripts/test_validate_payload.sh" >/dev/null 2>&1; then
      payload_tests_status="ok"
    else
      payload_tests_status="error"
      failed=1
    fi
  fi
  publish_tests_status="skipped"
  if [ -x "${ROOT}/scripts/test_publish_test_message.sh" ]; then
    if "${ROOT}/scripts/test_publish_test_message.sh" >/dev/null 2>&1; then
      publish_tests_status="ok"
    else
      publish_tests_status="error"
      failed=1
    fi
  fi

  if [[ "${prereqs_status}" != "ok" || "${rabbitmq_status}" != "ok" || "${topology_status}" == "error" ]]; then
    failed=1
  fi

  PREREQS_STATUS="${prereqs_status}" RABBITMQ_STATUS="${rabbitmq_status}" TOPOLOGY_STATUS="${topology_status}" \
  PAYLOAD_STATUS="${payload_status}" PAYLOAD_TESTS_STATUS="${payload_tests_status}" \
  PUBLISH_TESTS_STATUS="${publish_tests_status}" python3 - <<'PY'
import json,os
status="ok"
if os.environ.get("PREREQS_STATUS") != "ok":
    status="error"
if os.environ.get("RABBITMQ_STATUS") == "error":
    status="error"
if os.environ.get("TOPOLOGY_STATUS") == "error":
    status="error"
if os.environ.get("PAYLOAD_STATUS") != "ok":
    status="error"
if os.environ.get("PAYLOAD_TESTS_STATUS") == "error":
    status="error"
if os.environ.get("PUBLISH_TESTS_STATUS") == "error":
    status="error"
print(json.dumps({
    "status": status,
    "prereqs": os.environ.get("PREREQS_STATUS","error"),
    "rabbitmq": os.environ.get("RABBITMQ_STATUS","error"),
    "topology": os.environ.get("TOPOLOGY_STATUS","skipped"),
    "payload": os.environ.get("PAYLOAD_STATUS","error"),
    "payload_tests": os.environ.get("PAYLOAD_TESTS_STATUS","skipped"),
    "publish_tests": os.environ.get("PUBLISH_TESTS_STATUS","skipped"),
}))
PY
  exit "${failed}"
fi

if "${ROOT}/scripts/check_rabbitmq.sh" >/dev/null 2>&1; then
  if "${ROOT}/scripts/validate_rabbitmq.sh" >/dev/null 2>&1; then
    if [[ "${silent}" -eq 0 ]]; then
      echo "[ok] RabbitMQ topology validated"
    fi
  else
    echo "[warn] RabbitMQ topology invalid (run ./scripts/create_bindings.sh)" >&2
  fi
else
  echo "[warn] RabbitMQ management API unreachable" >&2
fi

"${ROOT}/scripts/validate_payload.py"
if [ -x "${ROOT}/scripts/test_validate_payload.sh" ]; then
  "${ROOT}/scripts/test_validate_payload.sh"
fi
if [ -x "${ROOT}/scripts/test_publish_test_message.sh" ]; then
  "${ROOT}/scripts/test_publish_test_message.sh"
fi
if [ -x "${ROOT}/scripts/publish_test_message_with_check.sh" ]; then
  "${ROOT}/scripts/publish_test_message_with_check.sh" --dry-run
fi

if [[ "${silent}" -eq 0 ]]; then
  echo "Doctor check completed."
fi
