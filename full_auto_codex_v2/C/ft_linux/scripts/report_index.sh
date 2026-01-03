#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/index.md"

mkdir -p "$REPORT_DIR"

{
	echo "# Reports index"
	echo ""
	echo "generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	for file in "$REPORT_DIR"/*; do
		[ -f "$file" ] || continue
		base=$(basename "$file")
		if [ "$base" = "index.md" ]; then
			continue
		fi
		size=$(stat -c%s "$file" 2>/dev/null || echo "0")
		echo "- $base ($size bytes)"
	done
} >"$OUT"

echo "Wrote $OUT"
