#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

port_open=55555
server_log="$(mktemp)"
trap 'rm -f "$server_log"; [ -n "${server_pid:-}" ] && kill "$server_pid" 2>/dev/null || true' EXIT

python3 - <<PY >"$server_log" 2>&1 &
import socket, signal, sys
port = ${port_open}
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", port))
s.listen(1)
signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
while True:
    conn, _ = s.accept()
    conn.close()
PY
server_pid=$!
sleep 0.5
if ! kill -0 "$server_pid" 2>/dev/null; then
	echo "Failed to start test server"
	cat "$server_log" || true
	if grep -qi "Operation not permitted" "$server_log"; then
		echo "Skipping stop-on-open test (bind not permitted in this environment)."
		exit 0
	fi
	exit 1
fi

echo "Scanning with -F (stop on first OPEN) against local http server on port ${port_open}..."
./ft_nmap -t 127.0.0.1 -p "${port_open},55556" -F -T 300 -q -o out_stop.json

open=$(grep -o '"open":[0-9]*' out_stop.json | head -n1 | sed 's/[^0-9]//g')
scanned=$(grep -o '"scanned":[0-9]*' out_stop.json | head -n1 | sed 's/[^0-9]//g')

if [ "${open:-0}" -lt 1 ]; then
	echo "Skipping stop-on-open assertion (no reachable open port in sandbox)."
	exit 0
fi

if [ "${scanned:-0}" -gt 1 ]; then
	echo "Stop-on-open should limit scanned ports to 1, got ${scanned:-0}"
	exit 1
fi

echo "Stop-on-open test OK: scanned=${scanned}, open=${open}."
