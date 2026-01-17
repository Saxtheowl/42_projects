#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"${ROOT}/scripts/setup_env.sh" || true
"${ROOT}/scripts/load_env.sh" || true
"${ROOT}/scripts/check_prereqs.sh"
"${ROOT}/scripts/smoke_local.sh"
"${ROOT}/scripts/status_report.sh"

echo "Local flow completed."
