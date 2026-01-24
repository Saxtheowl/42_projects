#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v mvn >/dev/null 2>&1; then
  echo "mvn is required." >&2
  exit 1
fi

if [[ "${1:-}" == "--list" ]]; then
  echo "services/producer"
  exit 0
fi

cd "${ROOT}/services/producer"
mvn test
