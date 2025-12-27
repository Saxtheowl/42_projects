#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

ports_file="$(mktemp)"
exclude_file="$(mktemp)"
out_json="$(mktemp)"
trap 'rm -f "$ports_file" "$exclude_file" "$out_json"' EXIT

printf '22\n80\n443\n' >"$ports_file"
printf '80\n' >"$exclude_file"

echo "Scanning with exclusions (-P file, -X exclude) to ensure skipped ports are not probed..."
./ft_nmap -t 127.0.0.1 -P "$ports_file" -X "$exclude_file" -T 200 -q -o "$out_json"

scanned=$(grep -o '"scanned":[0-9]*' "$out_json" | head -n1 | sed 's/[^0-9]//g')
if [ "${scanned:-0}" -ne 2 ]; then
	echo "Expected 2 scanned ports after exclusion, got ${scanned:-0}"
	exit 1
fi

excluded=$(grep -o '"excluded":[0-9]*' "$out_json" | head -n1 | sed 's/[^0-9]//g')
if [ "${excluded:-0}" -ne 1 ]; then
	echo "Expected excluded=1 in stats, got ${excluded:-0}"
	exit 1
fi

if grep -q '"port":80' "$out_json"; then
	echo "Port 80 should have been excluded but appears in JSON output"
	exit 1
fi

echo "Exclusion test OK: scanned=$scanned (22,443), excluded=$excluded, port 80 excluded."
