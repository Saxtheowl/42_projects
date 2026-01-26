#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi

usage() {
  cat <<'EOF'
Usage: ./scripts/build_modules.sh [--help] [--list]

Environment:
  MODULES  CSV list of module names or paths to build (default: all modules)
  ROOT_OVERRIDE  Override repository root for tests/stubs
EOF
}

list_only=0
for arg in "$@"; do
  case "${arg}" in
    --help)
      usage
      exit 0
      ;;
    --list)
      list_only=1
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

modules=(
  "services/producer"
  "services/consumers/food_application"
  "services/consumers/financial_assistance"
  "services/consumers/transportation_costs"
  "services/consumers/contracts"
  "services/consumers/grant_other_documents"
)

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

if [[ "${list_only}" -eq 1 ]]; then
  for module in "${modules[@]}"; do
    echo "${module}"
  done
  exit 0
fi

if ! command -v mvn >/dev/null 2>&1; then
  echo "mvn is required." >&2
  exit 1
fi

for module in "${modules[@]}"; do
  echo "Building ${module}..."
  (cd "${ROOT}/${module}" && mvn -q -DskipTests package)
  echo "OK"
done
