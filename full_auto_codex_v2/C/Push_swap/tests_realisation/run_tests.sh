#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$PROJECT_DIR/push_swap"
SIM="$PROJECT_DIR/tests_realisation/simulate.py"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

make -C "$PROJECT_DIR" >/dev/null

run_ok() {
    if ! "$BIN" "$@" >"$TMP_DIR/out" 2>"$TMP_DIR/err"; then
        echo "Expected success but failed for args: $*" >&2
        cat "$TMP_DIR/err" >&2
        exit 1
    fi
    if ! python3 "$SIM" "$@" <"$TMP_DIR/out" >"$TMP_DIR/sim"; then
        cat "$TMP_DIR/out" >&2
        exit 1
    fi
    if ! grep -q "OK" "$TMP_DIR/sim"; then
        echo "Simulation KO for args: $*" >&2
        cat "$TMP_DIR/sim" >&2
        exit 1
    fi
}

run_error() {
    if "$BIN" "$@" >"$TMP_DIR/out" 2>"$TMP_DIR/err"; then
        echo "Expected failure but succeeded for args: $*" >&2
        exit 1
    fi
    if ! grep -q "Error" "$TMP_DIR/err"; then
        echo "Expected 'Error' output for args: $*" >&2
        cat "$TMP_DIR/err" >&2
        exit 1
    fi
}

run_ok 2 1 3
run_ok 3 2 1
run_ok 3 1 2 6 5 4
run_ok "3 4 5 1 2"

run_error 1 2 2
run_error "1 2" "3 1"
run_error "abc" 3

echo "All push_swap tests passed."
