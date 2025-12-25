#!/bin/sh
CONF=${1:-tests/env/ft_services.conf}
TRIES=${2:-10}
DELAY=${3:-1}
COUNT=1
while [ $COUNT -le $TRIES ]; do
  echo "status check attempt $COUNT/$TRIES for $CONF"
  if ./scripts/check_status.sh "$CONF"; then
    echo "status check succeeded"
    exit 0
  fi
  COUNT=$((COUNT + 1))
  sleep "$DELAY"
done
echo "status check failed after $TRIES attempts" >&2
exit 1
