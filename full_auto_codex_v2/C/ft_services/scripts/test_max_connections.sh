#!/bin/sh
CONF=${1:-tests/env/ft_services.conf}
MAX=${2:-5}
PYTHON=$(command -v python3)
if [ -z "$PYTHON" ]; then
  echo "python3 not available" >&2
  exit 1
fi
$PYTHON - "$CONF" "$MAX" <<'PY'
import socket, sys
from pathlib import Path
if len(sys.argv) < 2:
    print("missing config", file=sys.stderr)
    sys.exit(1)
conf = Path(sys.argv[1])
max_conn = int(sys.argv[2]) if len(sys.argv) > 2 else 5
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
for i in range(max_conn):
    try:
        with socket.create_connection(('127.0.0.1', port), timeout=1) as sock:
            sock.sendall(b'STATUS\n')
            data = sock.recv(64)
            print(f"{i+1}: {data.decode().strip()}")
    except Exception as e:
        print(f"{i+1}: fail {e}")
        sys.exit(1)
PY
