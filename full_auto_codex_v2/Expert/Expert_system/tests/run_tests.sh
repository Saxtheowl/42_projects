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
  shift 2
  printf -- '---- %s ----\n' "$name"
  out="$("$BIN" "$@" "$SCRIPT_DIR/$name")"
  if [ "$out" = "$expected" ]; then
    printf -- '%s\n' "$out"
  else
    printf -- 'Expected:\n%s\nGot:\n%s\n' "$expected" "$out" >&2
    return 1
  fi
}

run simple_implication.exp "B: true"
run conflict.exp "B: undetermined (conflict)"
run or_resolution.exp "C: false
D: true"
run xor_branch.exp "B: false
C: true"
run or_conflict.exp "C: false
D: undetermined (conflict)"
run xor_conflict.exp "B: false
C: undetermined (conflict)"
run trace_conflict_input.exp "Rule #1 fired (progress): A => B
Conflict triggered by A => !B on B
Rule #1 fired (progress): A => B
Conflict triggered by A => !B on B
Known facts after fixpoint:
A: true
Rule #1 fired (progress): A => B
Conflict triggered by A => !B on B
B: undetermined (conflict)" -v
run simple_implication.exp "{\"results\":[{\"symbol\":\"B\",\"value\":\"true\",\"conflict\":false}]}" -j
run xor_mixed.exp "B: true
C: undetermined
D: undetermined"
run bicond.exp "B: true"
run demo.exp "C: true
D: false
E: true"
run bicond_chain.exp "B: true
C: true"
run neg_fact.exp "A: false"
run facts_conflict.exp "A: undetermined (conflict)"
run or_conflict_origin.exp "Conflicts detected:
B (from A => B | C) C (from A => B | C)
B: undetermined (conflict)
C: undetermined (conflict)" -c
run or_conflict_origin.exp "B: undetermined (conflict from A => B | C)
C: undetermined (conflict from A => B | C)" -o
run or_conflict_origin.exp "Conflicts detected:
B (from A => B | C) C (from A => B | C)
B: undetermined (conflict from A => B | C)
C: undetermined (conflict from A => B | C)" -co
