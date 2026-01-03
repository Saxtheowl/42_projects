#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_TXT="$ROOT/reports/env_audit.txt"
OUT_CSV="$ROOT/reports/env_audit.csv"

mkdir -p "$(dirname "$OUT_TXT")"

echo "env audit" >"$OUT_TXT"
echo "generated: $(date '+%Y-%m-%d %H:%M:%S')" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"

echo "tool,status" >"$OUT_CSV"

check_tool() {
	local tool="$1"
	if command -v "$tool" >/dev/null 2>&1; then
		echo "- $tool: ok" >>"$OUT_TXT"
		echo "$tool,ok" >>"$OUT_CSV"
	else
		echo "- $tool: missing" >>"$OUT_TXT"
		echo "$tool,missing" >>"$OUT_CSV"
	fi
}

for tool in curl sha256sum tar make gcc g++ ld as ar awk sed grep xargs; do
	check_tool "$tool"
done

echo "Wrote $OUT_TXT"
echo "Wrote $OUT_CSV"
