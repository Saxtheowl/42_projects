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

if [[ "${1:-}" == "--list" ]]; then
  for module in "${modules[@]}"; do
    echo "${module}"
  done
  exit 0
fi

MODULES="${MODULES:-}"
if [[ -n "${MODULES}" ]]; then
  IFS=',' read -r -a raw_targets <<< "${MODULES}"
  targets=()
  for target in "${raw_targets[@]}"; do
    trimmed="$(echo "${target}" | xargs)"
    if [[ -n "${trimmed}" ]]; then
      targets+=("${trimmed}")
    fi
  done

  filtered=()
  for module in "${modules[@]}"; do
    name="${module##*/}"
    for target in "${targets[@]}"; do
      if [[ "${module}" == "${target}" || "${name}" == "${target}" ]]; then
        filtered+=("${module}")
        break
      fi
    done
  done

  if [ "${#filtered[@]}" -eq 0 ]; then
    echo "No modules matched MODULES='${MODULES}'." >&2
    exit 1
  fi
  modules=("${filtered[@]}")
fi

for module in "${modules[@]}"; do
  echo "Testing ${module}..."
  (cd "${ROOT}/${module}" && mvn test)
  echo "OK"
done
