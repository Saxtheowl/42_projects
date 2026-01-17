#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"

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

curl -fsS -u "${USER}:${PASS}" "http://${HOST}:${PORT}/api/bindings/${vhost_enc}" \
  | python3 - <<'PY'
import json,sys
data=json.load(sys.stdin)
bindings=[]
for b in data:
    src=b.get("source","")
    dst=b.get("destination","")
    rk=b.get("routing_key","")
    if not src or not dst:
        continue
    bindings.append((src,dst,rk))
for src,dst,rk in sorted(bindings):
    print(f"{src} -> {dst} ({rk})")
PY
