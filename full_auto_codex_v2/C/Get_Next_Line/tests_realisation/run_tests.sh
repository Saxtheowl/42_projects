#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/tests_realisation"

cc -Wall -Wextra -Werror -Isrc -D BUFFER_SIZE=8 \
    "$PROJECT_DIR/src/get_next_line.c" \
    "$PROJECT_DIR/src/get_next_line_utils.c" \
    "$BUILD_DIR/test_gnl.c" \
    -o "$BUILD_DIR/test_gnl"

eq="First line\nSecond line without newline"
printf "%s" "${eq}" > "$BUILD_DIR/input.txt"

output=("$($BUILD_DIR/test_gnl "$BUILD_DIR/input.txt")")
expected="First line\nSecond line without newline"
if [[ "${output[*]}" != "$expected" ]]; then
    printf 'Test reading file failed\nExpected:\n%s\nGot:\n%s\n' "$expected" "${output[*]}" >&2
    exit 1
fi

echo -e "ABC\nDEF" | "$BUILD_DIR/test_gnl" > "$BUILD_DIR/stdout.txt"
if [[ $(cat "$BUILD_DIR/stdout.txt") != $'ABC\nDEF' ]]; then
    printf 'Test reading from stdin failed\n' >&2
    exit 1
fi

rm -f "$BUILD_DIR/test_gnl" "$BUILD_DIR/input.txt" "$BUILD_DIR/stdout.txt"
printf 'All tests passed.\n'
