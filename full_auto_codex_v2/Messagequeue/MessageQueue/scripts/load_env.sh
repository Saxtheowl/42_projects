#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-.env}"

if [ ! -f "${ENV_FILE}" ]; then
  echo "ENV file not found: ${ENV_FILE}" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "${ENV_FILE}"
set +a

echo "Loaded env from ${ENV_FILE}"

show_var() {
  local name="$1"
  if [ -n "${!name:-}" ]; then
    echo "[set] ${name}"
  else
    echo "[unset] ${name}"
  fi
}

show_var RABBITMQ_HOST
show_var RABBITMQ_PORT
show_var RABBITMQ_USER
show_var RABBITMQ_PASS
show_var RABBITMQ_VHOST
show_var EXCHANGE
show_var ROUTING_KEY
show_var QUEUE
show_var PAYLOAD_FILE
show_var PDF_OUTPUT_DIR
