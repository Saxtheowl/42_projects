#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
ARCHIVE_NAME=${1:-minishell_submission}
TMP_DIR=$(mktemp -d)

cleanup() {
	rm -rf "$TMP_DIR"
}
trap cleanup EXIT

pushd "$ROOT_DIR" >/dev/null

FILES=(
	"Makefile"
	"README.md"
	"PLAN.md"
	"Sujet_Minishell.pdf"
	"include"
	"src"
	"scripts"
	"tests_realisation"
)

for entry in "${FILES[@]}"; do
	if [ -e "$entry" ]; then
		rsync -a "$entry" "$TMP_DIR/"
	fi
done

rm -f "$TMP_DIR/scripts/package_release.sh" 2>/dev/null || true

tar -czf "${ARCHIVE_NAME}.tar.gz" -C "$TMP_DIR" .

popd >/dev/null

echo "Archive créée : ${ARCHIVE_NAME}.tar.gz"
