#!/usr/bin/env bash
set -euo pipefail

FILE="${FILE:-Messagequeue/MessageQueue/README.md}"
if [ ! -f "${FILE}" ]; then
  echo "README not found: ${FILE}" >&2
  exit 1
fi

echo "# Table of contents"

sed -n '1,200p' "${FILE}" | awk '
  /^## / {
    title = substr($0, 4)
    anchor = tolower(title)
    gsub(/[^a-z0-9 -]/, "", anchor)
    gsub(/ /, "-", anchor)
    print "- [" title "](#" anchor ")"
  }
'
