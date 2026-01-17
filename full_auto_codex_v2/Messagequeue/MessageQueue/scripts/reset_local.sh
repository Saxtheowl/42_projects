#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CLEAN_PDFS="${CLEAN_PDFS:-1}"
PURGE_QUEUES="${PURGE_QUEUES:-0}"
STOP_DOCKER="${STOP_DOCKER:-1}"

if [ "${CLEAN_PDFS}" -eq 1 ]; then
  rm -f "${ROOT}/shared/pdfs"/*
  echo "Cleaned shared/pdfs"
fi

if [ "${PURGE_QUEUES}" -eq 1 ]; then
  "${ROOT}/scripts/purge_queues.sh"
  echo "Purged queues"
fi

if [ "${STOP_DOCKER}" -eq 1 ]; then
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose -f "${ROOT}/docker-compose.yml" down
    echo "Stopped docker compose"
  else
    echo "docker compose not available; skipped stop"
  fi
fi
