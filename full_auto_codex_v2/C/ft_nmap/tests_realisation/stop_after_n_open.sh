#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

port1=55555
port2=55556
port_pending=55557
server_log="$(mktemp)"
trap 'rm -f "$server_log"; [ -n "${server_pid:-}" ] && kill "$server_pid" 2>/dev/null || true' EXIT

python3 - <<PY >"$server_log" 2>&1 &
import socket, signal, sys
p1 = ${port1}
p2 = ${port2}
sockets = []
try:
    for port in (p1, p2):
        sock = socket.socket()
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind(("127.0.0.1", port))
        sock.listen(1)
        sockets.append(sock)
except Exception as exc:
    for s in sockets:
        s.close()
    sys.exit(f"bind failed: {exc}")

def handle(sig, frame):
    for s in sockets:
        s.close()
    sys.exit(0)

signal.signal(signal.SIGTERM, handle)
while True:
    for s in sockets:
        try:
            conn, _ = s.accept()
            conn.close()
        except BlockingIOError:
            pass
PY
server_pid=$!
sleep 0.5
if ! kill -0 "$server_pid" 2>/dev/null; then
	echo "Failed to start test servers"
	cat "$server_log" || true
	if grep -qi "Operation not permitted" "$server_log"; then
		echo "Skipping stop-after-n-open test (bind not permitted in this environment)."
		exit 0
	fi
	exit 1
fi

echo "Scanning with -f 2 (stop after two OPEN ports)..."
out_json="$(mktemp)"
trap 'rm -f "$out_json"; rm -f "$server_log"; [ -n "${server_pid:-}" ] && kill "$server_pid" 2>/dev/null || true' EXIT

./ft_nmap -t 127.0.0.1 -p "${port1},${port2},${port_pending}" -f 2 -T 300 -q -o "$out_json"

python3 - <<'PY' "$out_json"
import json, sys
data = json.load(open(sys.argv[1], "r", encoding="utf-8"))
stats = data.get("stats", {})
ports = sorted(data.get("ports", []), key=lambda p: p.get("port", 0))
expected_open = 2
if stats.get("open", 0) < expected_open:
    print(f"Expected at least {expected_open} open ports, got {stats.get('open')}", file=sys.stderr)
    sys.exit(1)
if stats.get("scanned") != expected_open:
    print(f"Expected scanned={expected_open} due to early stop, got {stats.get('scanned')}", file=sys.stderr)
    sys.exit(1)
if stats.get("pending") != len(ports) - expected_open:
    print(f"Expected pending={len(ports)-expected_open}, got {stats.get('pending')}", file=sys.stderr)
    sys.exit(1)
open_ports = [p for p in ports if p.get("status") == "open"]
unknown_ports = [p for p in ports if p.get("status") == "unknown"]
if len(open_ports) < expected_open:
    print(f"Expected {expected_open} open entries in ports, got {len(open_ports)}", file=sys.stderr)
    sys.exit(1)
if len(unknown_ports) != 1:
    print(f"Expected 1 unknown (pending) entry, got {len(unknown_ports)}", file=sys.stderr)
    sys.exit(1)
PY

echo "Stop-after-n-open test OK."
