# ft_malcolm - ARP Tool (Educational)

Network security tool demonstrating ARP protocol concepts for educational purposes.

## Important Notice

This tool is for **educational purposes only**. Only use in:
- Your own private lab environment
- CTF competitions
- Authorized penetration testing
- Educational settings with permission

Unauthorized use on networks you don't own is illegal.

## Features

- Monitor ARP traffic
- Display ARP cache
- Resolve MAC addresses
- ARP spoofing demonstration (educational)

## Usage

```bash
# Monitor ARP traffic (requires root)
sudo python3 ft_malcolm.py monitor -i eth0

# Show system ARP table
python3 ft_malcolm.py table

# Resolve MAC address for an IP
sudo python3 ft_malcolm.py resolve -i eth0 -t 192.168.1.1

# ARP spoof demonstration (AUTHORIZED USE ONLY)
sudo python3 ft_malcolm.py spoof -i eth0 -t 192.168.1.10 -s 192.168.1.1
```

## Commands

### monitor
Monitor ARP traffic on an interface.

```bash
sudo python3 ft_malcolm.py monitor -i eth0 -c 10 -v
```

Options:
- `-i, --interface`: Network interface
- `-c, --count`: Number of packets (0=infinite)
- `-v, --verbose`: Show extra details

### table
Display the system's ARP cache.

```bash
python3 ft_malcolm.py table
```

### resolve
Resolve MAC address for an IP using ARP.

```bash
sudo python3 ft_malcolm.py resolve -i eth0 -t 192.168.1.1
```

### spoof
Send spoofed ARP replies (educational demonstration).

```bash
sudo python3 ft_malcolm.py spoof -i eth0 -t 192.168.1.10 -s 192.168.1.1
```

Options:
- `-t, --target`: Target IP address
- `-s, --spoof`: IP address to impersonate
- `-m, --mac`: Target MAC (auto-resolved if not provided)
- `--interval`: Time between packets (default: 1s)

## ARP Protocol Overview

### ARP Request
```
Who has 192.168.1.1? Tell 192.168.1.10 (aa:bb:cc:dd:ee:ff)
```

### ARP Reply
```
192.168.1.1 is at 11:22:33:44:55:66
```

### Packet Structure

```
Ethernet Frame (14 bytes):
+-------------------+-------------------+-----------+
| Destination MAC   | Source MAC        | EtherType |
| (6 bytes)         | (6 bytes)         | (2 bytes) |
+-------------------+-------------------+-----------+

ARP Packet (28 bytes):
+----------+----------+--------+--------+--------+
| HW Type  | Protocol | HW Len | Proto  | Opcode |
| (2)      | (2)      | (1)    | Len(1) | (2)    |
+----------+----------+--------+--------+--------+
| Sender MAC (6 bytes)                           |
+------------------------------------------------+
| Sender IP (4 bytes)                            |
+------------------------------------------------+
| Target MAC (6 bytes)                           |
+------------------------------------------------+
| Target IP (4 bytes)                            |
+------------------------------------------------+
```

## ARP Vulnerability

ARP has no authentication mechanism. Any host can:
1. Send unsolicited ARP replies
2. Claim to have any IP address
3. Update victim's ARP cache

This enables:
- Man-in-the-Middle attacks
- Network reconnaissance
- Denial of Service

## Defense Mechanisms

1. **Static ARP entries** - Manually configure critical entries
2. **ARP spoofing detection** - Monitor for anomalies
3. **802.1X authentication** - Port-based access control
4. **Dynamic ARP Inspection (DAI)** - Switch-level protection
5. **VLAN segmentation** - Limit broadcast domain

## Lab Setup

For safe testing:

```bash
# Create virtual network
sudo ip netns add ns1
sudo ip netns add ns2

# Create veth pairs
sudo ip link add veth0 type veth peer name veth1

# Assign to namespaces
sudo ip link set veth0 netns ns1
sudo ip link set veth1 netns ns2

# Configure IPs
sudo ip netns exec ns1 ip addr add 10.0.0.1/24 dev veth0
sudo ip netns exec ns2 ip addr add 10.0.0.2/24 dev veth1

# Bring up interfaces
sudo ip netns exec ns1 ip link set veth0 up
sudo ip netns exec ns2 ip link set veth1 up
```

## Requirements

- Python 3.6+
- Linux (uses raw sockets)
- Root privileges for packet operations

## Author

Implementation for 42 curriculum (security track).
