#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_json="$(mktemp)"
trap 'rm -f "$out_json"' EXIT

echo "Checking export filters (-E)..."
./ft_nmap -t 127.0.0.1 -p 22,80 -T 200 -q -o "$out_json" -E open

python3 - "$out_json" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
ports = data.get("ports", [])
stats = data.get("stats", {})
if stats.get("scanned") != 2:
    print(f"Expected scanned=2, got {stats.get('scanned')}", file=sys.stderr)
    sys.exit(1)
if len(ports) != 0:
    print(f"Expected ports array filtered to 0 when using -E open with no open ports, got {len(ports)}", file=sys.stderr)
    sys.exit(1)
PY

echo "Export filter test OK."
