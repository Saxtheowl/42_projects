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
Usage: ./scripts/run_local_flow.sh [--silent] [--json] [--help]

Options:
  --silent  Suppress output where supported.
  --json    Forward JSON output to subcommands where supported.
Environment:
  ROOT_OVERRIDE  Override repository root for tests/stubs
EOF
      exit 0
      ;;
    --silent)
      silent=1
      ;;
    --json)
      json_output=1
      silent=1
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

"${ROOT}/scripts/setup_env.sh" || true
"${ROOT}/scripts/load_env.sh" || true
"${ROOT}/scripts/check_prereqs.sh" "${args[@]}"
"${ROOT}/scripts/smoke_local.sh" "${args[@]}"
"${ROOT}/scripts/status_report.sh" "${args[@]}"

if [[ "${silent}" -eq 0 ]]; then
  echo "Local flow completed."
fi
