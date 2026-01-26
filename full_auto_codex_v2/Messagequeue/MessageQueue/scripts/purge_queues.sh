#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/purge_queues.sh [--help]

Environment:
  QUEUES  CSV list of queues to purge (default: standard set)
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

if [[ -n "${QUEUES:-}" ]]; then
  IFS=',' read -r -a QUEUE_LIST <<<"${QUEUES}"
  for i in "${!QUEUE_LIST[@]}"; do
    QUEUE_LIST[$i]="${QUEUE_LIST[$i]#"${QUEUE_LIST[$i]%%[![:space:]]*}"}"
    QUEUE_LIST[$i]="${QUEUE_LIST[$i]%"${QUEUE_LIST[$i]##*[![:space:]]}"}"
  done
else
  QUEUE_LIST=(
    food_application
    financial_assistance_application
    transportation_costs_application
    grant_other_documents
    grant_contracts
  )
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required." >&2
  exit 1
fi

vhost_enc=$(python3 - <<'PY'
import os,urllib.parse
v=os.environ.get("VHOST","/")
print(urllib.parse.quote(v, safe=""))
PY
)

for queue in "${QUEUE_LIST[@]}"; do
  curl -fsS -u "${USER}:${PASS}" -X DELETE \
    "http://${HOST}:${PORT}/api/queues/${vhost_enc}/${queue}/contents" >/dev/null
  echo "Purged ${queue}"
done
