#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v mvn >/dev/null 2>&1; then
  echo "mvn is required." >&2
  exit 1
fi

modules=(
  "services/consumers/food_application"
  "services/consumers/financial_assistance"
  "services/consumers/transportation_costs"
  "services/consumers/contracts"
  "services/consumers/grant_other_documents"
)

for module in "${modules[@]}"; do
  echo "Testing ${module}..."
  (cd "${ROOT}/${module}" && mvn test)
  echo "OK"
done
