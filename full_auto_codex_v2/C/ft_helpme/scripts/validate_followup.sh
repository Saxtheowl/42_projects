#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FOLLOWUP="${PROJECT_ROOT}/notes/review_followup.md"
DEBRIEF="${PROJECT_ROOT}/notes/debrief.md"

if [ ! -s "${FOLLOWUP}" ]; then
  echo "Review follow-up missing (notes/review_followup.md)." >&2
  exit 1
fi

required=(
  "scheduler" 
  "rmse_plot" 
  "validation"
)

missing=()
for term in "${required[@]}"; do
  if ! grep -qi "${term}" "${FOLLOWUP}"; then
    missing+=("${term}")
  fi
done

if [ ${#missing[@]} -ne 0 ]; then
  printf 'Follow-up missing keywords: %s\n' "${missing[*]}" >&2
  exit 1
fi

if [ ! -s "${DEBRIEF}" ]; then
  echo "Debrief still empty; fill notes/debrief.md after the review." >&2
  exit 1
fi

echo "Follow-up validated: review follow-up contains scheduler, rmse_plot, validation references. Debrief exists."
