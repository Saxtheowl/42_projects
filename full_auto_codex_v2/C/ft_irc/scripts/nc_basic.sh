#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
	echo "Usage: $0 <port> <password>" >&2
	exit 1
fi

PORT="$1"
PASSWORD="$2"

cat <<MSG | nc 127.0.0.1 "${PORT}"
PASS ${PASSWORD}
NICK testbot
USER testbot 0 * :Test Bot
JOIN #autotest
PRIVMSG #autotest :Hello from script
MSG
