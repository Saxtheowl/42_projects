#!/usr/bin/env bash
set -euo pipefail

for arg in "$@"; do
  case "${arg}" in
    --help)
      cat <<'EOF'
Usage: ./scripts/setup_env.sh [--help]

Environment:
  SRC  Source env file (default: .env.example)
  DST  Destination env file (default: .env)
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      exit 1
      ;;
  esac
done

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
