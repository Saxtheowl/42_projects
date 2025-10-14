#!/bin/bash
set -euo pipefail

format_bytes() {
    local kib=$1
    local unit="KB"
    local value=$kib
    if (( kib >= 1024 )); then
        value=$(awk -v v="$kib" 'BEGIN {printf "%.0f", v/1024}')
        unit="MB"
    fi
    if (( value >= 1024 )); then
        value=$(awk -v v="$value" 'BEGIN {printf "%.0f", v/1024}')
        unit="GB"
    fi
    printf "%s%s" "$value" "$unit"
}

arch=$(uname -a)
if command -v lscpu >/dev/null 2>&1; then
    physical_cpus=$(lscpu 2>/dev/null | awk -F: '/^Socket\(s\)/ {s=$2+0} /^Core\(s\) per socket/ {c=$2+0} END {if (s*c>0) print s*c; else print 0}')
fi
if [[ -z ${physical_cpus:-} || "${physical_cpus}" -le 0 ]]; then
    physical_cpus=$(grep -c '^physical id' /proc/cpuinfo 2>/dev/null || echo 0)
    if [[ "${physical_cpus}" -le 0 ]]; then
        physical_cpus=1
    fi
fi
virtual_cpus=$(nproc --all)

read -r _ mem_total mem_used _ < <(free --kilo | awk '/^Mem:/ {print $1,$2,$3,$4}')
mem_usage_percent=$(awk -v used="$mem_used" -v total="$mem_total" 'BEGIN {if (total==0) print "0"; else printf "%.2f", (used/total)*100}')

read -r disk_total_k disk_used_k disk_percent < <(df --total --block-size=1K | awk 'END {print $2, $3, $5}')
disk_usage_percent=${disk_percent%%%}

cpu_load=$(LANG=C top -bn1 | awk '/Cpu\(s\)/ {printf "%.1f", 100 - $8}')
if [[ -z $cpu_load ]]; then
    cpu_load=$(awk '/^cpu / {total=$2+$3+$4+$5+$6+$7+$8; idle=$5; if (total>0) printf "%.1f", 100*(1-idle/total);}' /proc/stat)
fi

last_boot=$(who -b | awk '{print $3" "$4}')
lvm_usage="no"
if lsblk -o TYPE | grep -q "lvm"; then
    lvm_usage="yes"
fi
if command -v ss >/dev/null 2>&1; then
    active_connections=$(ss -tan | awk 'NR>1 && /ESTAB/ {count++} END {print count+0}')
else
    active_connections=$(netstat -tan 2>/dev/null | awk 'NR>2 && /ESTABLISHED/ {count++} END {print count+0}')
fi
user_sessions=$(who | wc -l)
ipv4=$(hostname -I 2>/dev/null | awk '{print $1}')
mac_addr=$(ip link show | awk '/link\/ether/ {print $2; exit}')
sudo_commands=$(grep -c 'COMMAND=' /var/log/sudo/commands.log 2>/dev/null || echo 0)

output=$(cat <<REPORT
#Architecture: ${arch}
#CPU physical : ${physical_cpus}
#vCPU : ${virtual_cpus}
#Memory Usage: $(format_bytes "$mem_used")/$(format_bytes "$mem_total") (${mem_usage_percent}%)
#Disk Usage: $(format_bytes "$disk_used_k")/$(format_bytes "$disk_total_k") (${disk_usage_percent}%)
#CPU load: ${cpu_load}%
#Last boot: ${last_boot}
#LVM use: ${lvm_usage}
#Connections TCP : ${active_connections} ESTABLISHED
#User log: ${user_sessions}
#Network: IP ${ipv4:-N/A} (${mac_addr:-N/A})
#Sudo : ${sudo_commands} cmd
REPORT
)

wall "${output}"
