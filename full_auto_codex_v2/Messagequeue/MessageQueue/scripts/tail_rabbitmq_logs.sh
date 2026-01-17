#!/usr/bin/env bash
set -euo pipefail

SERVICE="${SERVICE:-rabbitmq}"
FOLLOW="${FOLLOW:-1}"
TAIL="${TAIL:-200}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required." >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose is required." >&2
  exit 1
fi

args=("logs" "--tail" "${TAIL}")
if [ "${FOLLOW}" -eq 1 ]; then
  args+=("-f")
fi
args+=("${SERVICE}")

docker compose "${args[@]}"
