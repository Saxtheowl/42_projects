#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must run as root." >&2
    exit 1
fi

USER_LOGIN="${1:-student}"
USER_PASSWORD="${2:-ChangeMe42!}"
ROOT_PASSWORD="${B2BR_ROOT_PASSWORD:-RootChangeMe42!}"
HOSTNAME_VALUE="${USER_LOGIN}42"
SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="${SCRIPT_DIR}/files"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    cryptsetup \
    gnupg \
    apparmor \
    net-tools \
    cron \
    lvm2 \
    openssh-server \
    rsync \
    sudo \
    ufw \
    vim \
    libpam-pwquality \
    auditd \
    parted

hostnamectl set-hostname "${HOSTNAME_VALUE}"

groupadd -f user42
id -u "${USER_LOGIN}" >/dev/null 2>&1 || adduser --disabled-password --gecos "" "${USER_LOGIN}"
echo "${USER_LOGIN}:${USER_PASSWORD}" | chpasswd
echo "root:${ROOT_PASSWORD}" | chpasswd
usermod -aG sudo,user42 "${USER_LOGIN}"

PASS_MAX_DAYS=30
PASS_MIN_DAYS=2
PASS_WARN_AGE=7

ensure_login_defs() {
    local key="$1" value="$2"
    if grep -qE "^${key}[[:space:]]" /etc/login.defs; then
        sed -i "s|^${key}.*|${key} ${value}|" /etc/login.defs
    else
        echo "${key} ${value}" >> /etc/login.defs
    fi
}

ensure_login_defs "PASS_MAX_DAYS" "${PASS_MAX_DAYS}"
ensure_login_defs "PASS_MIN_DAYS" "${PASS_MIN_DAYS}"
ensure_login_defs "PASS_WARN_AGE" "${PASS_WARN_AGE}"

if [ -f "${FILES_DIR}/pwquality.conf" ]; then
    install -m 0644 "${FILES_DIR}/pwquality.conf" /etc/security/pwquality.conf
fi

COMMON_PASSWORD_FILE="/etc/pam.d/common-password"
if ! grep -q "pam_pwquality.so" "${COMMON_PASSWORD_FILE}"; then
    echo "password requisite pam_pwquality.so retry=3" >> "${COMMON_PASSWORD_FILE}"
else
    sed -i 's|^password\s\+requisite\s\+pam_pwquality\.so.*|password requisite pam_pwquality.so retry=3|' "${COMMON_PASSWORD_FILE}"
fi

if ! grep -q "pam_unix.so" "${COMMON_PASSWORD_FILE}"; then
    echo "password [success=1 default=ignore] pam_unix.so obscure use_authtok try_first_pass sha512" >> "${COMMON_PASSWORD_FILE}"
else
    sed -i 's|^password\s\+\[success=1 default=ignore\]\s\+pam_unix\.so.*|password [success=1 default=ignore] pam_unix.so obscure use_authtok try_first_pass sha512|' "${COMMON_PASSWORD_FILE}"
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
declare -A ssh_settings=(
    [Port]=4242
    [PermitRootLogin]=no
    [PasswordAuthentication]=yes
    [ChallengeResponseAuthentication]=no
)
for key in "${!ssh_settings[@]}"; do
    if grep -qE "^${key}" "${SSHD_CONFIG}"; then
        sed -i "s|^${key}.*|${key} ${ssh_settings[$key]}|" "${SSHD_CONFIG}"
    else
        echo "${key} ${ssh_settings[$key]}" >> "${SSHD_CONFIG}"
    fi
done
systemctl restart ssh

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 4242/tcp
ufw --force enable

mkdir -p /var/log/sudo
chmod 750 /var/log/sudo
chown root:adm /var/log/sudo

SUDOERS_FILE="/etc/sudoers.d/born2beroot"
if [ -f "${FILES_DIR}/sudoers_born2beroot" ]; then
    install -m 0440 "${FILES_DIR}/sudoers_born2beroot" "${SUDOERS_FILE}"
else
    cat > "${SUDOERS_FILE}" <<'EOF'
Defaults passwd_tries=3
Defaults badpass_message="Incorrect password. Access denied."
Defaults logfile="/var/log/sudo/commands.log"
Defaults log_input,log_output
Defaults requiretty
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

%sudo ALL=(ALL) ALL
EOF
    chmod 440 "${SUDOERS_FILE}"
fi
visudo -c >/dev/null

LUKS_DEVICE="/dev/sdb"
LUKS_PARTITION="${LUKS_DEVICE}1"
CRYPT_NAME="cryptlvm"
VG_NAME="born2beroot-vg"
LV_VAR="lv_var"
LV_SRV="lv_srv"
PASS_FILE="/root/.luks_passphrase"

setup_storage() {
    if [ ! -b "${LUKS_DEVICE}" ]; then
        echo "Optional LVM disk ${LUKS_DEVICE} not found, skipping encrypted storage setup." >&2
        return
    fi

    if ! lsblk -no TYPE "${LUKS_PARTITION}" >/dev/null 2>&1; then
        parted --script "${LUKS_DEVICE}" mklabel gpt
        parted --script "${LUKS_DEVICE}" mkpart primary 0% 100%
    fi

    if [ ! -f "${PASS_FILE}" ]; then
        umask 077
        openssl rand -base64 48 > "${PASS_FILE}"
    fi

    if ! cryptsetup isLuks "${LUKS_PARTITION}"; then
        cryptsetup luksFormat --batch-mode "${LUKS_PARTITION}" "${PASS_FILE}"
    fi

    if ! lsblk -no NAME | grep -q "^${CRYPT_NAME}$"; then
        cryptsetup open "${LUKS_PARTITION}" "${CRYPT_NAME}" --key-file "${PASS_FILE}"
    fi

    if ! pvs | grep -q "${CRYPT_NAME}"; then
        pvcreate "/dev/mapper/${CRYPT_NAME}"
    fi
    if ! vgs | grep -q "^  ${VG_NAME}\b"; then
        vgcreate "${VG_NAME}" "/dev/mapper/${CRYPT_NAME}"
    fi
    if ! lvs "${VG_NAME}/${LV_VAR}" >/dev/null 2>&1; then
        lvcreate -L 4G -n "${LV_VAR}" "${VG_NAME}"
    fi
    if ! lvs "${VG_NAME}/${LV_SRV}" >/dev/null 2>&1; then
        lvcreate -l 100%FREE -n "${LV_SRV}" "${VG_NAME}"
    fi

    ensure_filesystem() {
        local device="$1"
        local fstype="$2"
        if ! blkid "${device}" >/dev/null 2>&1; then
            mkfs -t "${fstype}" "${device}"
        fi
    }

    ensure_filesystem "/dev/${VG_NAME}/${LV_VAR}" ext4
    ensure_filesystem "/dev/${VG_NAME}/${LV_SRV}" ext4

    if ! findmnt -rno SOURCE /var >/dev/null 2>&1 || ! findmnt -rno SOURCE /var | grep -q "${VG_NAME}-${LV_VAR}"; then
        mkdir -p /mnt/var-new
        mount "/dev/${VG_NAME}/${LV_VAR}" /mnt/var-new
        rsync -aHAX --delete /var/ /mnt/var-new/
        umount /mnt/var-new
        rmdir /mnt/var-new || true
        mount "/dev/${VG_NAME}/${LV_VAR}" /var
    fi

    if ! findmnt -rno SOURCE /srv >/dev/null 2>&1 || ! findmnt -rno SOURCE /srv | grep -q "${VG_NAME}-${LV_SRV}"; then
        mkdir -p /srv
        mount "/dev/${VG_NAME}/${LV_SRV}" /srv
    fi

    CRYPT_UUID="$(blkid -s UUID -o value "${LUKS_PARTITION}")"
    if ! grep -q "${CRYPT_NAME}" /etc/crypttab; then
        echo "${CRYPT_NAME} UUID=${CRYPT_UUID} ${PASS_FILE} luks,discard" >> /etc/crypttab
    fi

    VAR_UUID="$(blkid -s UUID -o value "/dev/${VG_NAME}/${LV_VAR}")"
    SRV_UUID="$(blkid -s UUID -o value "/dev/${VG_NAME}/${LV_SRV}")"

    if ! grep -q "${VAR_UUID}" /etc/fstab; then
        echo "UUID=${VAR_UUID} /var ext4 defaults 0 2" >> /etc/fstab
    fi
    if ! grep -q "${SRV_UUID}" /etc/fstab; then
        echo "UUID=${SRV_UUID} /srv ext4 defaults 0 2" >> /etc/fstab
    fi

    systemctl daemon-reload
}
setup_storage

chage --maxdays "${PASS_MAX_DAYS}" --mindays "${PASS_MIN_DAYS}" --warndays "${PASS_WARN_AGE}" "${USER_LOGIN}"
chage --maxdays "${PASS_MAX_DAYS}" --mindays "${PASS_MIN_DAYS}" --warndays "${PASS_WARN_AGE}" root

if command -v aa-status >/dev/null 2>&1; then
    aa-status >/dev/null 2>&1 || true
else
    if systemctl list-unit-files | grep -q '^apparmor\.service'; then
        systemctl enable --now apparmor
    fi
fi

echo "Base system provisioning complete."
