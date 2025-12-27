#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "Checking resolved IP export with -4 and override..."
./ft_nmap -4 -t example.com -I 127.0.0.1 -p 1 -q -J "$tmp"

python3 - <<'PY' "$tmp"
import json, sys
data = json.load(open(sys.argv[1]))
ip = data.get("resolved_ip", "")
family = data.get("resolved_family", "")
resolved = data.get("resolved", [])
assert ip == "127.0.0.1", f"resolved_ip must honor override, got {ip}"
assert family == "ipv4", f"expected ipv4 family, got {family!r}"
assert isinstance(resolved, list) and resolved, "resolved list must not be empty"
assert resolved[0].get("ip") == ip, "first resolved entry should match resolved_ip"
print(f"Resolved override to {ip} ({family})")
PY

echo "Resolved IP override test OK."
