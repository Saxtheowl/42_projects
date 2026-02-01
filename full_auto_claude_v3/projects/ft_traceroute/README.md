# ft_traceroute - Network Path Tracer

Traces the route packets take to a network host.

## Features

- UDP and ICMP probe modes
- Configurable TTL and probes
- Reverse DNS lookup
- Round-trip time measurement
- ICMP response parsing

## Usage

```bash
# Basic usage (requires root)
sudo ./ft_traceroute hostname

# Options
sudo ./ft_traceroute -m 20 -q 5 hostname    # 20 hops, 5 probes
sudo ./ft_traceroute -I hostname             # Use ICMP
```

## Options

| Option | Description |
|--------|-------------|
| `-m ttl` | Maximum number of hops (default: 30) |
| `-q n` | Number of probes per hop (default: 3) |
| `-I` | Use ICMP ECHO instead of UDP |
| `-h` | Show help |

## Building

```bash
make
```

## How It Works

1. Send probe packets with incrementing TTL
2. When TTL expires, routers send ICMP Time Exceeded
3. Record responding IP and round-trip time
4. Continue until destination reached or max hops

## Output

```
traceroute to example.com (93.184.216.34), 30 hops max, 60 byte packets
 1  router.local (192.168.1.1)  1.234 ms  1.456 ms  1.678 ms
 2  10.0.0.1  5.123 ms  5.234 ms  5.345 ms
...
```

## Author

Implementation for 42 curriculum.
