#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_json="$(mktemp)"
trap 'rm -f "$out_json"' EXIT

echo "Checking inter-batch delay (-w) impacts elapsed time..."
start_ns=$(date +%s%N)
./ft_nmap -t 127.0.0.1 -p 22 -T 100 -w 100 -q -o "$out_json"
end_ns=$(date +%s%N)

elapsed_cli_ms=$(( (end_ns - start_ns) / 1000000 ))
elapsed_json=$(grep -o '"elapsed_ms":[0-9]*' "$out_json" | head -n1 | sed 's/[^0-9]//g')

# Allow some slack; expect at least ~80ms in JSON and CLI elapsed >= elapsed_json
if [ "${elapsed_json:-0}" -lt 80 ]; then
	echo "Expected elapsed_ms >= 80 with delay, got ${elapsed_json:-0}"
	exit 1
fi
if [ "${elapsed_cli_ms:-0}" -lt "${elapsed_json:-0}" ]; then
	echo "CLI timing shorter than JSON reported elapsed: cli=${elapsed_cli_ms}, json=${elapsed_json}"
	exit 1
fi

echo "Inter-batch delay test OK: elapsed_json=${elapsed_json}ms, elapsed_cli=${elapsed_cli_ms}ms."
