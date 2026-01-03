#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/env_prereqs.txt"
DOC="$ROOT/scripts/host_requirements.md"

mkdir -p "$REPORT_DIR"

cmds=(
	bash
	make
	gcc
	g++
	ld
	as
	bison
	flex
	makeinfo
	awk
	patch
	tar
	xz
)

missing=0
{
	echo "Host prerequisites check"
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	for cmd in "${cmds[@]}"; do
		if command -v "$cmd" >/dev/null 2>&1; then
			printf "[OK] %s -> %s\n" "$cmd" "$(command -v "$cmd")"
		else
			printf "[MISS] %s\n" "$cmd"
			missing=$((missing + 1))
		fi
	done
	echo ""
	if [ "$missing" -eq 0 ]; then
		echo "Result: OK"
	else
		echo "Result: MISSING ($missing)"
	fi
	echo ""
	if [ -f "$DOC" ]; then
		echo "Checklist: $DOC"
	fi
} >"$OUT"

echo "[OK] Host prereqs report: $OUT"
