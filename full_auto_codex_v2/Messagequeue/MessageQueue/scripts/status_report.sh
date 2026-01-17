#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"${ROOT}/scripts/check_prereqs.sh" >/dev/null

printf '%s\n' "RabbitMQ status report" "======================" ""

if "${ROOT}/scripts/check_rabbitmq.sh" >/dev/null 2>&1; then
  echo "[ok] management API reachable"
else
  echo "[missing] management API unreachable" >&2
  exit 1
fi

echo
printf '%s\n' "Queues:" "------"
"${ROOT}/scripts/count_queue_messages.sh"

echo
printf '%s\n' "Exchanges:" "---------"
"${ROOT}/scripts/list_exchanges.sh"

echo
printf '%s\n' "Bindings:" "---------"
"${ROOT}/scripts/list_bindings.sh"
