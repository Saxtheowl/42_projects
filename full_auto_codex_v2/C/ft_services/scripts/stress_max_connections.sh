#!/bin/sh
CONFIG=${1:-tests/env/ft_services_status.conf}
MAX=${2:-15}
if [ ! -f "$CONFIG" ]; then
  echo "Config $CONFIG absent" >&2
  exit 1
fi
HOST=$(awk -F= '/^host/ {print $2; exit}' "$CONFIG" | tr -d ' \t')
PORT=$(awk -F= '/^port/ {print $2; exit}' "$CONFIG" | tr -d ' \t')
HOST=${HOST:-127.0.0.1}
PORT=${PORT:-4242}
COUNTER=0
while [ $COUNTER -lt "$MAX" ]; do
  RESPONSE=$(printf "STATUS\n" | nc "$HOST" "$PORT")
  printf "[%s] STATUS -> %s\n" "$COUNTER" "$RESPONSE"
  if echo "$RESPONSE" | grep -q 'overloaded'; then
    echo "overloaded triggered at iteration $COUNTER"
    exit 0
  fi
  COUNTER=$((COUNTER + 1))
done
printf "no overload in %s tries\n" "$MAX"
exit 1
