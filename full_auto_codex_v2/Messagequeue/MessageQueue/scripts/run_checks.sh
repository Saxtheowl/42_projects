#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"${ROOT}/scripts/doctor.sh"
"${ROOT}/scripts/test_routing_matrix.sh"

echo "Checks completed."
