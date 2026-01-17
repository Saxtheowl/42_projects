#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PORT=4243
COUNT=5

if ! make -s; then
  echo "Build failed" >&2
  exit 1
fi

SERVER_LOG="$(mktemp)"
CLIENT_LOG="$(mktemp)"

cleanup() {
  rm -f "$SERVER_LOG" "$CLIENT_LOG"
}
trap cleanup EXIT

if ! python3 - <<'PY'
import socket
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.close()
except PermissionError:
    raise SystemExit(1)
PY
then
  echo "Skipping UDP mock test (socket permission denied)."
  exit 0
fi

./kalman_demo --udp "$PORT" "$COUNT" >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!

sleep 0.2
python3 ./scripts/mock_stream.py "$PORT" "$COUNT" >"$CLIENT_LOG"

wait "$SERVER_PID"

RESPONSES="$(rg -c "^{\"step\":" "$CLIENT_LOG" || true)"
if [ "$RESPONSES" -ne "$COUNT" ]; then
  echo "Expected $COUNT responses, got $RESPONSES" >&2
  echo "--- server log ---" >&2
  cat "$SERVER_LOG" >&2
  echo "--- client log ---" >&2
  cat "$CLIENT_LOG" >&2
  exit 1
fi

echo "UDP mock test OK ($RESPONSES responses)."
