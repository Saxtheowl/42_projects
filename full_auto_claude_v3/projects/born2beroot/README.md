# Born2beRoot - System Administration

Virtual machine setup and system administration project.

## Note

This project requires creating a virtual machine from scratch.
Below is the comprehensive setup guide.

## Overview

Set up a secure Debian/Rocky Linux server with:
- Encrypted partitions (LVM)
- Strong password policy
- SSH configuration
- Firewall (UFW/firewalld)
- Sudo configuration
- User management
- Monitoring script

## Partition Scheme (Bonus)

```
sda
├── sda1          500M    /boot
└── sda2          max     encrypted
    └── LVMGroup
        ├── root   10G    /
        ├── swap   2.3G   [SWAP]
        ├── home   5G     /home
        ├── var    3G     /var
        ├── srv    3G     /srv
        ├── tmp    3G     /tmp
        └── var-log 4G    /var/log
```

## Installation Steps

### 1. Create Virtual Machine
- VirtualBox or UTM
- 8GB+ disk
- 1GB+ RAM
- No GUI (server install)

### 2. Partition with LVM + Encryption
```bash
# During installation:
# 1. Select "Guided - use entire disk and set up encrypted LVM"
# 2. Set encryption passphrase
# 3. Create logical volumes as shown above
```

### 3. Install Base System
```bash
# Minimal installation
# Set hostname: login42
# Create user: login
```

## Post-Installation Configuration

### 4. SSH Setup

```bash
# Install SSH
apt install openssh-server

# Edit /etc/ssh/sshd_config
Port 4242
PermitRootLogin no
PasswordAuthentication yes

# Restart SSH
systemctl restart sshd
```

### 5. Firewall (UFW)

```bash
# Install UFW
apt install ufw

# Configure
ufw default deny incoming
ufw default allow outgoing
ufw allow 4242

# Enable
ufw enable
ufw status
```

### 6. Sudo Configuration

```bash
# Install sudo
apt install sudo

# Add user to sudo group
usermod -aG sudo login

# Configure /etc/sudoers.d/sudoconfig
Defaults        passwd_tries=3
Defaults        badpass_message="Wrong password. Try again."
Defaults        logfile="/var/log/sudo/sudo.log"
Defaults        log_input, log_output
Defaults        iolog_dir="/var/log/sudo"
Defaults        requiretty
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# Create log directory
mkdir -p /var/log/sudo
```

### 7. Password Policy

```bash
# Install libpam-pwquality
apt install libpam-pwquality

# Edit /etc/login.defs
PASS_MAX_DAYS   30
PASS_MIN_DAYS   2
PASS_WARN_AGE   7

# Edit /etc/pam.d/common-password
# Add to pam_pwquality.so line:
password requisite pam_pwquality.so retry=3 minlen=10 ucredit=-1 dcredit=-1 lcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root

# Apply to existing users
chage -M 30 -m 2 -W 7 login
chage -M 30 -m 2 -W 7 root
```

### 8. Hostname Configuration

```bash
# Set hostname
hostnamectl set-hostname login42

# Edit /etc/hosts
127.0.0.1   localhost
127.0.1.1   login42
```

### 9. User Groups

```bash
# Create user42 group
groupadd user42

# Add user to groups
usermod -aG user42 login

# Verify
groups login
```

## Monitoring Script

Create `/usr/local/bin/monitoring.sh`:

```bash
#!/bin/bash

# Architecture
arch=$(uname -a)

# Physical CPUs
pcpu=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)

# Virtual CPUs
vcpu=$(grep -c "^processor" /proc/cpuinfo)

# RAM
ram_total=$(free -m | awk '/Mem:/ {print $2}')
ram_used=$(free -m | awk '/Mem:/ {print $3}')
ram_percent=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2*100}')

# Disk
disk_total=$(df -BG --total | awk '/total/ {print $2}' | tr -d 'G')
disk_used=$(df -BM --total | awk '/total/ {print $3}' | tr -d 'M')
disk_percent=$(df --total | awk '/total/ {print $5}')

# CPU Load
cpu_load=$(top -bn1 | grep "Cpu(s)" | awk '{printf("%.1f%%"), $2+$4}')

# Last Boot
last_boot=$(who -b | awk '{print $3" "$4}')

# LVM
lvm_use=$(if [ $(lsblk | grep -c "lvm") -gt 0 ]; then echo yes; else echo no; fi)

# TCP Connections
tcp=$(ss -s | grep "TCP:" | awk '{print $4}' | tr -d ',')

# Users
users=$(who | wc -l)

# IP and MAC
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link | grep "link/ether" | awk '{print $2}')

# Sudo commands
sudo_cmds=$(grep -c "COMMAND" /var/log/sudo/sudo.log 2>/dev/null || echo 0)

# Display
wall "
    #Architecture: $arch
    #CPU physical: $pcpu
    #vCPU: $vcpu
    #Memory Usage: ${ram_used}/${ram_total}MB (${ram_percent}%)
    #Disk Usage: ${disk_used}/${disk_total}Gb (${disk_percent})
    #CPU load: $cpu_load
    #Last boot: $last_boot
    #LVM use: $lvm_use
    #Connections TCP: $tcp ESTABLISHED
    #User log: $users
    #Network: IP $ip ($mac)
    #Sudo: $sudo_cmds cmd
"
```

### Cron Setup

```bash
# Make executable
chmod +x /usr/local/bin/monitoring.sh

# Edit crontab
crontab -e

# Add (runs every 10 minutes)
*/10 * * * * /usr/local/bin/monitoring.sh
```

## Verification Commands

```bash
# Check partitions
lsblk

# Check UFW status
ufw status

# Check SSH config
systemctl status sshd

# Check hostname
hostnamectl

# Check sudo log
cat /var/log/sudo/sudo.log

# Check password policy
chage -l login

# Check groups
getent group sudo
getent group user42

# Check crontab
crontab -l

# Run monitoring manually
/usr/local/bin/monitoring.sh
```

## Evaluation Checklist

- [ ] VM uses Debian or Rocky Linux
- [ ] No graphical interface
- [ ] Encrypted partitions with LVM
- [ ] SSH on port 4242 only
- [ ] UFW enabled (only port 4242)
- [ ] Hostname is login42
- [ ] Strong password policy implemented
- [ ] Sudo configured with logging
- [ ] User in sudo and user42 groups
- [ ] Monitoring script runs every 10 minutes
- [ ] Can explain all configurations

## Bonus Features

- WordPress with lighttpd, MariaDB, PHP
- Additional service of choice
- Extra functional partitions

## Signature

Generate VM signature:
```bash
# For VirtualBox
sha1sum /path/to/vm.vdi > signature.txt

# For UTM
shasum /path/to/vm.utm/Images/disk-0.qcow2 > signature.txt
```

## Author

System administration guide for 42 curriculum.
