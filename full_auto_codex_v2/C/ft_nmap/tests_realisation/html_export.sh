#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_html="$(mktemp)"
trap 'rm -f "$out_html"' EXIT

echo "Checking HTML export..."
./ft_nmap -t 127.0.0.1 -p 22,80 -T 200 -q -H "$out_html"

if [ ! -s "$out_html" ]; then
	echo "HTML report not generated" >&2
	exit 1
fi

head -n 5 "$out_html" | grep -q "<html" || { echo "Missing HTML header" >&2; exit 1; }
grep -q "<table" "$out_html" || { echo "Missing table in HTML report" >&2; exit 1; }
grep -q "Ports" "$out_html" || { echo "Missing ports section title" >&2; exit 1; }

echo "HTML export test OK."
