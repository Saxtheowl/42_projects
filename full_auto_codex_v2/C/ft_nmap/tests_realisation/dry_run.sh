#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_json="$(mktemp)"
trap 'rm -f "$out_json"' EXIT

echo "Checking dry-run mode skips sockets but still exports stats..."
./ft_nmap -t 127.0.0.1 -p 80,81 -n -q -o "$out_json"

python3 - "$out_json" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)
stats = data.get("stats", {})
assert stats.get("dry_run") is True, "stats.dry_run should be true in dry-run mode"
assert stats.get("scanned") == 0, f"expected scanned=0, got {stats.get('scanned')}"
requested = stats.get("requested")
pending = stats.get("pending")
assert requested == 2, f"expected requested=2, got {requested}"
assert pending == requested, f"pending should equal requested in dry-run (got {pending})"
for key in ("open", "closed", "timeouts"):
    assert stats.get(key) == 0, f"{key} should remain 0 in dry-run (got {stats.get(key)})"
ports = data.get("ports", [])
assert len(ports) == 2, f"expected 2 ports in export, got {len(ports)}"
statuses = {p.get("status") for p in ports}
assert statuses == {"unknown"}, f"ports should stay unknown in dry-run, got {statuses}"
print("Dry-run JSON export looks good.")
PY

echo "Dry-run mode test OK."
