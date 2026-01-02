#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

cat > "$workdir/targets.txt" <<'TXT'
127.0.0.1
localhost
TXT

echo "Checking multi-target scanning via -i with per-target exports..."
./ft_nmap -i "$workdir/targets.txt" -p 22 -n -q -o "$workdir/out_%s.json" -J "$workdir/summary_%s.json"

[ -f "$workdir/out_127.0.0.1.json" ] || { echo "missing 127.0.0.1 export"; exit 1; }
[ -f "$workdir/out_localhost.json" ] || { echo "missing localhost export"; exit 1; }
[ -f "$workdir/summary_127.0.0.1.json" ] || { echo "missing 127.0.0.1 summary"; exit 1; }
[ -f "$workdir/summary_localhost.json" ] || { echo "missing localhost summary"; exit 1; }

echo "Multi-target export test OK."
