#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

make -C "$PROJECT_DIR" re
PYTHONPATH="$PROJECT_DIR/tests_realisation" python3 -m unittest tests_realisation.test_malloc
