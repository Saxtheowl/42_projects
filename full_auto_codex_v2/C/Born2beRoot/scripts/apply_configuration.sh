#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGIN="${B2BR_LOGIN:-${USER}}"
PASSWORD="${B2BR_PASSWORD:-ChangeMe42!}"

main() {
    sudo "${PROJECT_ROOT}/provisioning/00-system-prep.sh" "${LOGIN}" "${PASSWORD}"
    sudo "${PROJECT_ROOT}/provisioning/10-monitoring.sh"
    echo "Configuration applied."
}

main "$@"
