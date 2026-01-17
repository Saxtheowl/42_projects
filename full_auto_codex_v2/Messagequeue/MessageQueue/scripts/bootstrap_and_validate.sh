#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"${ROOT}/scripts/check_rabbitmq.sh"
"${ROOT}/scripts/bootstrap_rabbitmq.sh"
"${ROOT}/scripts/validate_rabbitmq.sh"
