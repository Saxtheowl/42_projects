#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_md="$(mktemp)"
trap 'rm -f "$out_md"' EXIT

echo "Checking Markdown export..."
./ft_nmap -t 127.0.0.1 -p 22,80 -T 200 -q -m "$out_md"

if [ ! -s "$out_md" ]; then
	echo "Markdown report not generated" >&2
	exit 1
fi

head -n 1 "$out_md" | grep -q "# ft_nmap report" || { echo "Missing Markdown header" >&2; exit 1; }
grep -q "| Port | Status |" "$out_md" || { echo "Missing ports table" >&2; exit 1; }

echo "Markdown export test OK."
