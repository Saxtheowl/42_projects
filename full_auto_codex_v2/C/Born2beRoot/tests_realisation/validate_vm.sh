#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGIN="${B2BR_LOGIN:-student}"

cd "${PROJECT_DIR}"

if ! command -v vagrant >/dev/null 2>&1; then
    echo "vagrant command not found. Install Vagrant to validate the VM." >&2
    exit 2
fi

state="$(vagrant status --machine-readable 2>/dev/null | awk -F, '$3 == "state-human-short" {print $4; exit}')"
if [[ -z "${state}" || "${state}" != "running" ]]; then
    echo "The Born2beRoot VM must be running. Use: vagrant up" >&2
    exit 3
fi

vm_exec() {
    local remote="$1"
    local quoted
    quoted="$(printf '%q' "${remote}")"
    vagrant ssh -c "bash -lc ${quoted}"
}

failures=0

run_check() {
    local description="$1"
    local command="$2"
    if vm_exec "${command}" >/dev/null 2>&1; then
        printf '[OK]   %s\n' "${description}"
    else
        printf '[FAIL] %s\n' "${description}"
        failures=$((failures + 1))
    fi
}

run_check "User ${LOGIN} exists" "id ${LOGIN}"
run_check "User ${LOGIN} is part of sudo group" "id -nG ${LOGIN} | tr ' ' '\n' | grep -qx 'sudo'"
run_check "Hostname matches <login>42" "hostnamectl --static | grep -qx '${LOGIN}42'"
run_check "SSH listens on port 4242" "sudo grep -q '^Port 4242' /etc/ssh/sshd_config"
run_check "UFW is enabled" "sudo ufw status | grep -q 'Status: active'"
run_check "UFW allows 4242/tcp" "sudo ufw status | grep -q '4242/tcp'"
run_check "Monitoring script installed" "sudo test -x /usr/local/sbin/monitoring.sh"
run_check "Cron entry for monitoring every 10 minutes" "sudo grep -q '*/10' /etc/cron.d/monitoring"
run_check "Sudo policy enforces passwd_tries=3" "sudo grep -q '^Defaults passwd_tries=3' /etc/sudoers.d/born2beroot"
run_check "Sudo logs to /var/log/sudo/commands.log" "sudo grep -q 'logfile=\"/var/log/sudo/commands.log\"' /etc/sudoers.d/born2beroot"
run_check "Password policy (pam_pwquality) in place" "sudo grep -q 'pam_pwquality.so retry=3' /etc/pam.d/common-password"
run_check "Password aging (max 30 days) for ${LOGIN}" "sudo chage -l ${LOGIN} | grep -q 'Maximum number of days.*30'"
run_check "Password aging (max 30 days) for root" "sudo chage -l root | grep -q 'Maximum number of days.*30'"
run_check "Encrypted LVM volumes detected" "sudo lsblk -o TYPE | grep -q 'lvm'"

if (( failures > 0 )); then
    printf '\nValidation failed (%d check(s) in error).\n' "${failures}" >&2
    exit 4
fi

echo
echo "All Born2beRoot runtime checks passed."
