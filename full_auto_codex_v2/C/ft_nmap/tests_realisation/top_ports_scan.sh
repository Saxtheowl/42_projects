#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_json="$(mktemp)"
trap 'rm -f "$out_json"' EXIT

echo "Scanning top 5 common ports (-k 5)..."
./ft_nmap -t 127.0.0.1 -k 5 -q -o "$out_json"

scanned=$(grep -o '"scanned":[0-9]*' "$out_json" | head -n1 | sed 's/[^0-9]//g')
if [ "${scanned:-0}" -ne 5 ]; then
	echo "Expected scanned=5 with -k 5, got ${scanned:-0}"
	exit 1
fi

python3 - "$out_json" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
ports = sorted([p["port"] for p in data.get("ports", [])])
expected = [21, 22, 25, 80, 443]
if ports != expected:
    print(f"Unexpected ports for -k 5: got {ports}, expected {expected}", file=sys.stderr)
    sys.exit(1)
PY

echo "Top ports test OK: scanned=5 with expected common ports."
