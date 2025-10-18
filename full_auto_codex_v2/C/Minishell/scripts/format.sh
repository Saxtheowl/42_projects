#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

printf 'No formatter configured yet. Use norminette and manual clang-format where allowed.\n'
printf 'Project root: %s\n' "${PROJECT_ROOT}"
