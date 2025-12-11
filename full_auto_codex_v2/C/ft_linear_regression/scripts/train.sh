#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
VENV="${PROJECT_ROOT}/.venv/bin/python"
DATASET="${PROJECT_ROOT}/data/data.csv"
HISTORY="${PROJECT_ROOT}/data/history.json"

if [ ! -x "${VENV}" ]; then
	printf 'Python venv not found. Create it with `python3 -m venv .venv`\n' >&2
	exit 1
fi

"${VENV}" "${PROJECT_ROOT}/src/train.py" "${DATASET}" --history "${HISTORY}" "$@"
