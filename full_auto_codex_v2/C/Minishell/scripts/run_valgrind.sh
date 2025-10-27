#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
BIN="$ROOT_DIR/minishell"

VALGRIND_BIN=${VALGRIND_BIN:-valgrind}
VALGRIND_ARGS=${VALGRIND_ARGS:---leak-check=full --show-leak-kinds=all --errors-for-leak-kinds=all --track-origins=yes --quiet --error-exitcode=98}

if ! command -v "$VALGRIND_BIN" >/dev/null 2>&1; then
	echo "valgrind indisponible : installez-le puis relancez ce script." >&2
	exit 127
fi

if [ ! -x "$BIN" ]; then
	echo "Binaire minishell introuvable. Lancez 'make' avant d'exécuter ce script." >&2
	exit 1
fi

run_case() {
	local name=$1
	shift
	printf '%s\n' "$@" | "$VALGRIND_BIN" $VALGRIND_ARGS "$BIN" >/dev/null
	echo "[OK] $name"
}

echo "=== Valgrind smoke tests ==="
run_case "echo simple" "echo salut" "exit"
run_case "pipeline + export" "export MINI=42" "echo foo | tr a-z A-Z" "unset MINI" "exit"
run_case "heredoc basique" "cat <<EOF" "hello" "EOF" "exit"
echo "=== Fin ==="
