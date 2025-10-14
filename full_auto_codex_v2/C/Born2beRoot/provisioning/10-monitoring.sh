#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must run as root." >&2
    exit 1
fi

SCRIPT_SRC="/vagrant/scripts/monitoring.sh"
SCRIPT_DST="/usr/local/sbin/monitoring.sh"
CRON_FILE="/etc/cron.d/monitoring"

if [ -f "${SCRIPT_SRC}" ]; then
    install -m 0755 "${SCRIPT_SRC}" "${SCRIPT_DST}"
else
    echo "Warning: monitoring script not found at ${SCRIPT_SRC}" >&2
fi

cat > "${CRON_FILE}" <<'EOF_CRON'
*/10 * * * * root /usr/local/sbin/monitoring.sh
EOF_CRON
chmod 0644 "${CRON_FILE}"

mkdir -p /var/log/sudo
chmod 750 /var/log/sudo
chown root:adm /var/log/sudo

systemctl restart cron

if command -v auditctl >/dev/null 2>&1; then
    systemctl enable --now auditd
fi

echo "Monitoring provisioning complete."
