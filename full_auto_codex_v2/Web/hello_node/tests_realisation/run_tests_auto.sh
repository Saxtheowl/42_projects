#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if node -e 'const net=require("net");const server=net.createServer();server.on("error",()=>process.exit(1));server.listen(0,"127.0.0.1",()=>server.close(()=>process.exit(0)));'; then
  node "$PROJECT_DIR/tests_realisation/check_hello_node.js"
else
  HELLO_NODE_SKIP_NET=1 node "$PROJECT_DIR/tests_realisation/check_hello_node.js"
fi
