#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! make -s; then
  echo "Build failed" >&2
  exit 1
fi

echo "Running demo..."
./kalman_demo | head -n 5

echo "Running kalman_test..."
make -s test
