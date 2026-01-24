#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"
SOURCES="${SOURCES:-}"
DESTINATIONS="${DESTINATIONS:-}"
ROUTING_KEYS="${ROUTING_KEYS:-}"
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/list_bindings.sh [--help] [--silent] [--json]

Environment:
  SOURCES       CSV list of binding sources
  DESTINATIONS  CSV list of binding destinations
  ROUTING_KEYS  CSV list of routing keys
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

output=$(curl -fsS -u "${USER}:${PASS}" "http://${HOST}:${PORT}/api/bindings/${vhost_enc}" \
  | SOURCES="${SOURCES}" DESTINATIONS="${DESTINATIONS}" ROUTING_KEYS="${ROUTING_KEYS}" JSON_OUTPUT="${json_output}" python3 - <<'PY'
import json,sys
def parse_set(value):
    items=set()
    raw=value.strip()
    if not raw:
        return items
    for part in raw.split(","):
        name=part.strip()
        if name:
            items.add(name)
    return items

sources=parse_set(os.environ.get("SOURCES",""))
destinations=parse_set(os.environ.get("DESTINATIONS",""))
routing_keys=parse_set(os.environ.get("ROUTING_KEYS",""))
json_output = os.environ.get("JSON_OUTPUT") == "1"
data=json.load(sys.stdin)
bindings=[]
for b in data:
    src=b.get("source","")
    dst=b.get("destination","")
    rk=b.get("routing_key","")
    if not src or not dst:
        continue
    if sources and src not in sources:
        continue
    if destinations and dst not in destinations:
        continue
    if routing_keys and rk not in routing_keys:
        continue
    bindings.append((src,dst,rk))
if json_output:
    items=[{"source": src, "destination": dst, "routing_key": rk} for src,dst,rk in sorted(bindings)]
    print(json.dumps(items))
else:
    for src,dst,rk in sorted(bindings):
        print(f"{src} -> {dst} ({rk})")
PY
)

if [[ "${json_output}" -eq 1 || "${silent}" -eq 0 ]]; then
  printf '%s\n' "${output}"
fi
