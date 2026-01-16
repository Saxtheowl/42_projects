#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

make -C "$ROOT" >/dev/null

cc -Wall -Wextra -Werror -I"$ROOT/inc" \
    "$ROOT/tests_realisation/test_libft.c" \
    -L"$ROOT" -lft \
    -o "$ROOT/tests_realisation/test_libft"

"$ROOT/tests_realisation/test_libft"

rm -f "$ROOT/tests_realisation/test_libft"
