#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="${PROJECT_DIR}/.tools/shellcheck"
PATH="${TOOLS_DIR}:${PATH}"

if ! command -v shellcheck >/dev/null 2>&1; then
    if [ -x "${PROJECT_DIR}/scripts/install_shellcheck.sh" ]; then
        "${PROJECT_DIR}/scripts/install_shellcheck.sh"
        PATH="${TOOLS_DIR}:${PATH}"
    fi
fi

if ! command -v shellcheck >/dev/null 2>&1; then
    echo "shellcheck is required but could not be installed." >&2
    exit 1
fi

shellcheck \
    "${PROJECT_DIR}/provisioning/00-system-prep.sh" \
    "${PROJECT_DIR}/provisioning/10-monitoring.sh" \
    "${PROJECT_DIR}/scripts/monitoring.sh" \
    "${PROJECT_DIR}/scripts/apply_configuration.sh" \
    "${PROJECT_DIR}/tests_realisation/validate_vm.sh" \
    "${PROJECT_DIR}/scripts/generate_signature.sh"

PROJECT_DIR="${PROJECT_DIR}" python3 - <<'PY'
import os
from pathlib import Path

project = Path(os.environ["PROJECT_DIR"])
content = (project / "provisioning" / "00-system-prep.sh").read_text()
required = [
    "Port]=4242",
    "passwd_tries=3",
    "badpass_message",
    "logfile=\"/var/log/sudo/commands.log\"",
    "ufw allow 4242/tcp",
]
missing = [item for item in required if item not in content]
if missing:
    raise SystemExit(f"Provisioning script missing expected tokens: {missing}")

vagrant = (project / "Vagrantfile").read_text()
if "guest: 4242" not in vagrant:
    raise SystemExit("Vagrant file must forward port 4242")
PY

echo "All Born2beRoot static checks passed."
