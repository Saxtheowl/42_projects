#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

keys=(
  "grant.application"
  "grant.guarantee"
  "grant.1.contract"
  "grant.2.contract"
)

"${ROOT}/scripts/check_prereqs.sh" >/dev/null

for key in "${keys[@]}"; do
  echo "Publishing ${key}..."
  EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="${key}" "${ROOT}/scripts/publish_test_message.sh" >/dev/null
  echo "OK"
done

