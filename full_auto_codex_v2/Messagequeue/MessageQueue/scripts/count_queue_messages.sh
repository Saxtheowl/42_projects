#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"
QUEUES="${QUEUES:-}"
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/count_queue_messages.sh [--help] [--silent] [--json]

Environment:
  QUEUES  CSV list of queue names to filter
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

output=$(curl -fsS -u "${USER}:${PASS}" "http://${HOST}:${PORT}/api/queues/${vhost_enc}" \
  | QUEUES="${QUEUES}" JSON_OUTPUT="${json_output}" python3 - <<'PY'
import json,sys
queues_env=os.environ.get("QUEUES","")
targets=set()
if queues_env.strip():
    for part in queues_env.split(","):
        name=part.strip()
        if name:
            targets.add(name)
data=json.load(sys.stdin)
json_output = os.environ.get("JSON_OUTPUT") == "1"
items=[]
for q in sorted(data, key=lambda x: x.get("name","")):
    name=q.get("name","")
    if not name:
        continue
    if targets and name not in targets:
        continue
    count=q.get("messages", 0)
    items.append({"name": name, "messages": count})
if json_output:
    print(json.dumps(items))
else:
    for item in items:
        print(f"{item['name']}\t{item['messages']}")
PY
)

if [[ "${json_output}" -eq 1 || "${silent}" -eq 0 ]]; then
  printf '%s\n' "${output}"
fi
