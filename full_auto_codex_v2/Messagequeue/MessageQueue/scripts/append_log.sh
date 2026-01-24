#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <timestamp> <category/project> <status> <message>" >&2
  exit 1
fi

ts="$1"
cat_project="$2"
status="$3"
shift 3
message="$*"

printf '%s | %s | %s | %s\n' "${ts}" "${cat_project}" "${status}" "${message}" >> progress.md
printf 'Derniere mise a jour (%s) : %s %s : %s\n' "${ts}" "${cat_project}" "${status}" "${message}" >> README.md
