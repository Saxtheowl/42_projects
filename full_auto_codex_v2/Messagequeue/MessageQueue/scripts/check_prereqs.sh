#!/usr/bin/env bash
set -euo pipefail

missing=0
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/check_prereqs.sh [--help] [--silent] [--json]

Environment:
  SKIP_DOCKER  Skip docker checks (default: 0)
  SKIP_MVN     Skip mvn checks (default: 0)
EOF
    exit 0
  elif [[ "${arg}" == "--silent" ]]; then
    silent=1
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

status_lines=()
missing_items=()

add_status() {
  status_lines+=("$1")
}

flush_status() {
  if [[ "${silent}" -eq 0 ]]; then
    printf '%s\n' "${status_lines[@]}"
  fi
}

check_cmd() {
  local name="$1"
  local hint="$2"
  if command -v "${name}" >/dev/null 2>&1; then
    add_status "[ok] ${name}"
  else
    add_status "[missing] ${name} (${hint})"
    missing_items+=("${name}")
    missing=1
  fi
}

check_cmd curl "required for RabbitMQ management API scripts"
check_cmd python3 "required for URL encoding and JSON helpers"

if [[ "${SKIP_DOCKER:-0}" != "1" ]]; then
  check_cmd docker "required to run local RabbitMQ via docker compose"
else
  add_status "[skip] docker (SKIP_DOCKER=1)"
fi

if [[ "${SKIP_MVN:-0}" != "1" ]]; then
  check_cmd mvn "required to build/run Java modules"
else
  add_status "[skip] mvn (SKIP_MVN=1)"
fi

if [[ "${SKIP_DOCKER:-0}" != "1" ]] && command -v docker >/dev/null 2>&1; then
  if docker compose version >/dev/null 2>&1; then
    add_status "[ok] docker compose"
  else
    add_status "[missing] docker compose (required for local RabbitMQ)"
    missing_items+=("docker compose")
    missing=1
  fi
fi

if [[ "${json_output}" -eq 1 ]]; then
  if command -v python3 >/dev/null 2>&1; then
    python_code=$'import json,sys\nmissing=[line.strip() for line in sys.stdin if line.strip()]\nstatus="error" if missing else "ok"\nprint(json.dumps({"status": status, "missing": missing}))'
    printf '%s\n' "${missing_items[@]}" | python3 -c "${python_code}"
  else
    printf '%s\n' "{\"status\":\"error\",\"missing\":[\"python3\"]}"
  fi
  exit "${missing}"
fi

flush_status
if [ "${missing}" -ne 0 ]; then
  echo "Some prerequisites are missing." >&2
  exit 1
fi
