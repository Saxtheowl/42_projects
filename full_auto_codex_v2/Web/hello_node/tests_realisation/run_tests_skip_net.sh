#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

HELLO_NODE_SKIP_NET=1 node "$PROJECT_DIR/tests_realisation/check_hello_node.js"
