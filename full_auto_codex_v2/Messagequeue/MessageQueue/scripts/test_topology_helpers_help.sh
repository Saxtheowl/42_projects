#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

check_help() {
  local script="$1"
  local needle="$2"
  if [[ ! -x "${script}" ]]; then
    echo "Missing ${script}" >&2
    exit 1
  fi
  local help_output
  help_output=$("${script}" --help)
  if ! printf '%s' "${help_output}" | rg -q -- "${needle}"; then
    echo "Expected ${script} --help to mention ${needle}." >&2
    exit 1
  fi
}

check_help "${ROOT_DIR}/scripts/list_queues.sh" "QUEUES"
check_help "${ROOT_DIR}/scripts/list_exchanges.sh" "EXCHANGES"
check_help "${ROOT_DIR}/scripts/list_bindings.sh" "ROUTING_KEYS"
check_help "${ROOT_DIR}/scripts/count_queue_messages.sh" "QUEUES"
check_help "${ROOT_DIR}/scripts/status_report.sh" "QUEUE_FILTER"

check_help "${ROOT_DIR}/scripts/list_queues.sh" "--json"
check_help "${ROOT_DIR}/scripts/list_exchanges.sh" "--json"
check_help "${ROOT_DIR}/scripts/list_bindings.sh" "--json"
check_help "${ROOT_DIR}/scripts/count_queue_messages.sh" "--json"

printf '%s\n' "[ok] topology helpers help tests passed"
