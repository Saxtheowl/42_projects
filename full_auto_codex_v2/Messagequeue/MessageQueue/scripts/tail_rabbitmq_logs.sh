#!/usr/bin/env bash
set -euo pipefail

SERVICE="${SERVICE:-rabbitmq}"
FOLLOW="${FOLLOW:-1}"
TAIL="${TAIL:-200}"

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/tail_rabbitmq_logs.sh [--help]

Environment:
  SERVICE  Docker compose service name (default: rabbitmq)
  FOLLOW   Follow logs (default: 1)
  TAIL     Number of lines to show (default: 200)
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

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
