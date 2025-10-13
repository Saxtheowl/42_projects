#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHONPATH="$PROJECT_DIR" python3 -m unittest discover -s "$PROJECT_DIR/tests_realisation" -p "test_*.py"
