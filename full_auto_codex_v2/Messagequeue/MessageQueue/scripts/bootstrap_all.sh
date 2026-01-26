#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi
silent=0
json_output=0

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/bootstrap_all.sh [--silent] [--json] [--help]

Options:
  --silent  Suppress output where supported.
  --json    Forward JSON output to subcommands where supported.
EOF
      exit 0
      ;;
    --silent)
      silent=1
      ;;
    --json)
      json_output=1
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

args=()
if [[ "${silent}" -eq 1 ]]; then
  args+=(--silent)
fi
if [[ "${json_output}" -eq 1 ]]; then
  args+=(--json)
fi

docker compose -f "${ROOT}/docker-compose.yml" up -d
"${ROOT}/scripts/wait_rabbitmq.sh" "${args[@]}"
"${ROOT}/scripts/bootstrap_rabbitmq.sh" "${args[@]}"
"${ROOT}/scripts/validate_rabbitmq.sh" "${args[@]}"
"${ROOT}/scripts/test_routing.sh" "${args[@]}"
