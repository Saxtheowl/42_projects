#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$PROJECT_DIR/pipex"

if ! make -C "$PROJECT_DIR" >/dev/null; then
    echo "Build failed" >&2
    exit 1
fi

tempdir=$(mktemp -d)
trap 'rm -rf "$tempdir"' EXIT

cat <<'TXT' > "$tempdir/input.txt"
hello world
test line
foo bar
hello again
TXT

cat <<'TXT' > "$tempdir/input2.txt"
alpha beta gamma
42 school pipex
TXT

run_case() {
    local infile=$1
    local cmd1=$2
    local cmd2=$3
    local outfile_pipex=$4
    local outfile_shell=$5

    "$BIN" "$infile" "$cmd1" "$cmd2" "$outfile_pipex"
    sh -c "<$infile $cmd1 | $cmd2" > "$outfile_shell"
    if ! diff -u "$outfile_shell" "$outfile_pipex"; then
        echo "Test failed: $cmd1 | $cmd2" >&2
        exit 1
    fi
}

run_case "$tempdir/input.txt" "grep hello" "wc -l" "$tempdir/out1" "$tempdir/ref1"
run_case "$tempdir/input2.txt" "tr a-z A-Z" "cut -d' ' -f1" "$tempdir/out2" "$tempdir/ref2"
run_case "$tempdir/input2.txt" "cat" "sed 's/ /_/g'" "$tempdir/out3" "$tempdir/ref3"

echo "All pipex tests passed."
