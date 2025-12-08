#!/bin/sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$SCRIPT_DIR/../expert"
if [ ! -x "$BIN" ]; then
  echo "Build the project first (make)" >&2
  exit 1
fi

run() {
  name="$1"
  expected="$2"
  printf -- '---- %s ----\n' "$name"
  out="$("$BIN" "$SCRIPT_DIR/$name")"
  if [ "$out" = "$expected" ]; then
    printf -- '%s\n' "$out"
  else
    printf -- 'Expected:\n%s\nGot:\n%s\n' "$expected" "$out" >&2
    return 1
  fi
}

run simple_implication.exp "B: true"
run conflict.exp "B: undetermined"
run or_resolution.exp "C: false
D: true"
run xor_branch.exp "B: false
C: true"
run or_conflict.exp "C: false
D: undetermined"
run xor_conflict.exp "B: false
C: undetermined"
run xor_mixed.exp "B: true
C: undetermined
D: undetermined"
run bicond.exp "B: true"
run demo.exp "C: true
D: false
E: true"
