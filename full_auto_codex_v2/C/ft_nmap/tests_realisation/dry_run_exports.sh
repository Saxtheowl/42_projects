#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

csv="$(mktemp)"; yaml="$(mktemp)"; xml="$(mktemp)"; md="$(mktemp)"
trap 'rm -f "$csv" "$yaml" "$xml" "$md"' EXIT

echo "Checking dry-run mode marks exports across CSV/YAML/XML/Markdown..."
./ft_nmap -t 127.0.0.1 -p 80,81 -n -q -C "$csv" -Y "$yaml" -Z "$xml" -m "$md"

grep -q "dry_run" "$csv" || { echo "dry_run missing in CSV header/body"; exit 1; }
grep -q "true" "$csv" || { echo "dry_run value not found in CSV"; exit 1; }
grep -q "version,0.2.0" "$csv" || { echo "version missing in CSV header"; exit 1; }
grep -q "dry_run: true" "$yaml" || { echo "dry_run missing in YAML"; exit 1; }
grep -q "version: \"0.2.0\"" "$yaml" || { echo "version missing in YAML"; exit 1; }
grep -q 'dry_run="true"' "$xml" || { echo "dry_run missing in XML"; exit 1; }
grep -q 'version="0.2.0"' "$xml" || { echo "version missing in XML"; exit 1; }
grep -q "dry_run: true" "$md" || { echo "dry_run missing in Markdown report"; exit 1; }
grep -q "\\*\\*Version\\*\\*: 0.2.0" "$md" || { echo "version missing in Markdown report"; exit 1; }

echo "Dry-run flag exported correctly across formats."
