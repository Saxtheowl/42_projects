#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$PROJECT_DIR/so_long"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

make -C "$PROJECT_DIR" MLX=0 >/dev/null

run_ok() {
    if ! "$BIN" "$@" >"$TMP_DIR/out" 2>"$TMP_DIR/err"; then
        echo "Expected success but failed for args: $*" >&2
        cat "$TMP_DIR/err" >&2
        exit 1
    fi
}

run_err() {
    if "$BIN" "$@" >"$TMP_DIR/out" 2>"$TMP_DIR/err"; then
        echo "Expected failure but succeeded for args: $*" >&2
        exit 1
    fi
}

run_ok "$PROJECT_DIR/assets/maps/level1.ber"

echo "111" > "$TMP_DIR/bad.ber"
run_err "$TMP_DIR/bad.ber"

cat <<'MAP' > "$TMP_DIR/blocked.ber"
111111
1P0011
111111
1C0E11
111111
MAP
run_err "$TMP_DIR/blocked.ber"

echo "All so_long parsing tests passed."
