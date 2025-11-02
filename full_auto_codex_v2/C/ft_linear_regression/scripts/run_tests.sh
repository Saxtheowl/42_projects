#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
VENV="${PROJECT_ROOT}/.venv/bin/python"

if [ ! -x "${VENV}" ]; then
	printf 'Python venv not found. Create it with `python3 -m venv .venv`\n' >&2
	exit 1
fi

"${VENV}" -m pytest "${PROJECT_ROOT}/tests_realisation"
