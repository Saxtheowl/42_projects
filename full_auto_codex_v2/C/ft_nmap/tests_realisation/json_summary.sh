#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_sum="$(mktemp)"
trap 'rm -f "$out_sum"' EXIT

echo "Checking JSON summary-only export..."
./ft_nmap -t 127.0.0.1 -p 22,80 -T 200 -q -J "$out_sum"

python3 - <<'PY' "$out_sum"
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
assert "stats" in data, "Missing stats object"
assert data.get("version") == "0.2.0", f"Expected version 0.2.0, got {data.get('version')}"
assert "target" in data and "timeout_ms" in data, "Missing header fields"
assert data.get("resolved_ip") == "127.0.0.1", "resolved_ip should expose numeric target"
assert data.get("resolved_family") == "ipv4", "resolved_family should report address family"
resolved = data.get("resolved", [])
assert isinstance(resolved, list) and len(resolved) >= 1, "resolved array should be present"
assert any(entry.get("ip") == "127.0.0.1" for entry in resolved), "resolved list must include 127.0.0.1"
stats = data["stats"]
for key in ("requested", "scanned", "open", "closed", "timeouts", "elapsed_ms"):
    assert key in stats, f"Missing stats key {key}"
assert "ports" not in data, "Summary JSON must not include ports"
print("Summary JSON parsed OK.")
PY

echo "JSON summary-only test OK."
