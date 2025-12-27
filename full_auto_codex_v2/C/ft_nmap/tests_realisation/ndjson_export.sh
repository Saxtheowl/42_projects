#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_ndjson="$(mktemp)"
trap 'rm -f "$out_ndjson"' EXIT

echo "Exporting per-port NDJSON lines..."
./ft_nmap -t 127.0.0.1 -p 22,80,443 -N "$out_ndjson" -T 200 -q

lines=$(wc -l <"$out_ndjson" | tr -d ' ')
if [ "${lines:-0}" -ne 3 ]; then
	echo "Expected 3 NDJSON lines, got ${lines:-0}"
	exit 1
fi

python3 - "$out_ndjson" <<'PY'
import json, sys
ports = []
with open(sys.argv[1], "r", encoding="utf-8") as f:
    for line in f:
        try:
            ports.append(json.loads(line)["port"])
        except Exception as exc:
            print(f"Invalid NDJSON line: {exc}", file=sys.stderr)
            sys.exit(1)
if ports != sorted(ports):
    print(f"Ports not sorted in NDJSON: {ports}", file=sys.stderr)
    sys.exit(1)
PY

if ! head -n1 "$out_ndjson" | grep -q '"port":22'; then
	echo "NDJSON content missing expected port fields"
	exit 1
fi

echo "NDJSON export test OK: ${lines} lines written."
