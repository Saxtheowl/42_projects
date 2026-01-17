#!/usr/bin/env bash
set -euo pipefail

missing=0

check_cmd() {
  local name="$1"
  local hint="$2"
  if command -v "${name}" >/dev/null 2>&1; then
    echo "[ok] ${name}"
  else
    echo "[missing] ${name} (${hint})"
    missing=1
  fi
}

check_cmd curl "required for RabbitMQ management API scripts"
check_cmd python3 "required for URL encoding and JSON helpers"
check_cmd docker "required to run local RabbitMQ via docker compose"
check_cmd mvn "required to build/run Java modules"

if command -v docker >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    echo "[ok] docker compose"
  else
    echo "[missing] docker compose (required for local RabbitMQ)"
    missing=1
  fi
fi

if [ "${missing}" -ne 0 ]; then
  echo "Some prerequisites are missing." >&2
  exit 1
fi
