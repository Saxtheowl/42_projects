#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_json="$(mktemp)"
trap 'rm -f "$out_json"' EXIT

echo "Running deadline-limited scan..."
./ft_nmap -t 127.0.0.1 -p 1-50 -c 1 -T 50 -w 1500 -M 500 -q -o "$out_json" >/dev/null

python3 - "$out_json" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
stats = data.get("stats", {})
ports = data.get("ports", [])
if not stats.get("deadline_hit"):
    print("deadline_hit flag not set in stats", file=sys.stderr)
    sys.exit(1)
if stats.get("elapsed_ms", 0) < stats.get("deadline_ms", 0):
    print(f"Elapsed ms {stats.get('elapsed_ms')} below deadline {stats.get('deadline_ms')}", file=sys.stderr)
    sys.exit(1)
if stats.get("delay_ms") != 1500:
    print(f"delay_ms mismatch: {stats.get('delay_ms')}", file=sys.stderr)
    sys.exit(1)
if len(ports) != stats.get("requested"):
    print(f"Ports array length {len(ports)} does not match requested {stats.get('requested')}", file=sys.stderr)
    sys.exit(1)
PY

echo "Deadline scan test OK."
