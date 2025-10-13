#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 "$PROJECT_DIR/tests_realisation/check_hello_vue.py"
