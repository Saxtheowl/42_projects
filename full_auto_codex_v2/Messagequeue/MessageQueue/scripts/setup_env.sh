#!/usr/bin/env bash
set -euo pipefail

SRC="${SRC:-.env.example}"
DST="${DST:-.env}"

if [ ! -f "${SRC}" ]; then
  echo "Source env file not found: ${SRC}" >&2
  exit 1
fi

if [ -f "${DST}" ]; then
  echo "${DST} already exists."
  exit 0
fi

cp "${SRC}" "${DST}"

echo "Created ${DST} from ${SRC}."
