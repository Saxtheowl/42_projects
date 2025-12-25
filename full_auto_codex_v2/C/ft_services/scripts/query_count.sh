#!/bin/sh
CONF=${1:-tests/env/ft_services.conf}
PYTHON=$(command -v python3)
if [ -z "$PYTHON" ]; then
  echo "python3 not available" >&2
  exit 1
fi
$PYTHON - "$CONF" <<'PY'
import socket, sys
from pathlib import Path
if len(sys.argv) < 2:
    print("missing config", file=sys.stderr)
    sys.exit(1)
conf = Path(sys.argv[1])
if not conf.exists():
    print(f"missing config {conf}", file=sys.stderr)
    sys.exit(1)
port = 4242
with conf.open() as f:
    for line in f:
        line=line.strip()
        if not line or line.startswith('#'):
            continue
        key,value=line.split('=',1)
        if key=='port':
            port=int(value)
host='127.0.0.1'
try:
    with socket.create_connection((host, port), timeout=2) as sock:
        sock.sendall(b'COUNT\n')
        data=sock.recv(64)
        print(data.decode().strip())
except Exception as err:
    print(f"count check failed: {err}", file=sys.stderr)
    sys.exit(1)
PY
