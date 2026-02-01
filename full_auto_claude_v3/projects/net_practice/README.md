# Net Practice - Network Configuration Tool

A tool to practice and understand IP addressing, subnetting, and routing.

## Features

- Subnet calculator
- IP address validation
- Network topology modeling
- Route validation
- Connectivity testing
- Interactive exercises

## Usage

```bash
# Calculate subnet information
python3 net_practice.py calc 192.168.1.100/24

# Random subnet exercise
python3 net_practice.py exercise

# View example network
python3 net_practice.py example

# Interactive mode
python3 net_practice.py interactive
```

## Subnet Calculator

```bash
$ python3 net_practice.py calc 192.168.1.100/24

Subnet Calculator: 192.168.1.100/24
========================================
IP Address:      192.168.1.100
Subnet Mask:     255.255.255.0
CIDR Notation:   /24
Network Address: 192.168.1.0
Broadcast:       192.168.1.255
First Host:      192.168.1.1
Last Host:       192.168.1.254
Total Hosts:     254
IP Class:        C
Private:         Yes
```

## Interactive Mode

```
> device Router router
Added router: Router

> interface Router eth0 192.168.1.1 255.255.255.0
Added interface eth0 to Router

> interface Router eth1 10.0.0.1 255.255.255.0
Added interface eth1 to Router

> device Client host
Added host: Client

> interface Client eth0 192.168.1.10 255.255.255.0
Added interface eth0 to Client

> route Client 0.0.0.0 0.0.0.0 192.168.1.1 eth0
Added route to Client

> connect Client eth0 Router eth0
Connected Client.eth0 <-> Router.eth0

> validate
Network configuration is valid!

> test Client 10.0.0.50
Path:
  Client -> 192.168.1.1 via eth0
  Router.eth1 -> 10.0.0.50 (direct)
Result: Reachable
```

## Concepts

### IP Address Classes

| Class | First Octet | Default Mask | Range |
|-------|-------------|--------------|-------|
| A | 1-126 | /8 | 10.0.0.0/8 (private) |
| B | 128-191 | /16 | 172.16.0.0/12 (private) |
| C | 192-223 | /24 | 192.168.0.0/16 (private) |
| D | 224-239 | - | Multicast |
| E | 240-255 | - | Reserved |

### CIDR Notation

| CIDR | Mask | Hosts |
|------|------|-------|
| /8 | 255.0.0.0 | 16,777,214 |
| /16 | 255.255.0.0 | 65,534 |
| /24 | 255.255.255.0 | 254 |
| /25 | 255.255.255.128 | 126 |
| /26 | 255.255.255.192 | 62 |
| /27 | 255.255.255.224 | 30 |
| /28 | 255.255.255.240 | 14 |
| /29 | 255.255.255.248 | 6 |
| /30 | 255.255.255.252 | 2 |

### Subnetting Rules

1. **Network Address**: First address (all host bits = 0)
2. **Broadcast Address**: Last address (all host bits = 1)
3. **Usable Hosts**: Total - 2 (network and broadcast)
4. **Same Network**: IPs with same network address can communicate directly

### Routing

- Routes match destination by longest prefix (most specific wins)
- Default route: 0.0.0.0/0 matches everything
- Gateway must be directly reachable

## Example Network

```
┌─────────────┐     ┌──────────┐     ┌──────────────┐
│   Client    │     │  Router  │     │    Server    │
│192.168.1.10 │─────│   eth0   │     │  10.0.0.10   │
│    /24      │     │.1     .1 │─────│     /24      │
└─────────────┘     │   eth1   │     └──────────────┘
                    └──────────┘
      192.168.1.0/24    │     10.0.0.0/24
                        │
```

## Net Practice Levels

The 42 Net Practice project includes 10 levels of increasing difficulty:

1. Basic IP configuration
2. Multiple interfaces
3. Simple routing
4. Subnetting
5. Complex routing
6. Internet connectivity
7. Multiple networks
8. Route aggregation
9. Full topology
10. Advanced scenario

## Validation Checks

- IP not network/broadcast address
- Mask is contiguous
- Connected interfaces in same network
- Gateway is reachable
- No IP conflicts

## Requirements

- Python 3.6+
- No external dependencies

## Author

Implementation for 42 curriculum (networking).
