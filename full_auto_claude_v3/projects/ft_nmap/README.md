# ft_nmap - Network Scanner

Port scanning and service detection tool for network reconnaissance.

## Features

- TCP connect scanning
- UDP scanning
- Multi-threaded scanning
- Service detection
- Banner grabbing
- Common port database
- Host discovery

## Usage

```bash
python3 ft_nmap.py <target> [options]
python3 ft_nmap.py --demo    # Run demo
```

## Options

| Option | Description |
|--------|-------------|
| `-p <ports>` | Ports to scan (22,80,443 or 1-1024) |
| `-sT` | TCP connect scan (default) |
| `-sU` | UDP scan |
| `--top <n>` | Scan top N common ports |
| `-t <threads>` | Number of threads (default: 100) |
| `--timeout <s>` | Timeout in seconds (default: 1.0) |

## Examples

```bash
# Scan specific ports
python3 ft_nmap.py 192.168.1.1 -p 22,80,443

# Scan port range
python3 ft_nmap.py 192.168.1.1 -p 1-1024

# Scan top 100 common ports
python3 ft_nmap.py example.com --top 100

# UDP scan
python3 ft_nmap.py 192.168.1.1 -sU -p 53,67,123

# Adjust threads and timeout
python3 ft_nmap.py 192.168.1.1 -t 200 --timeout 0.5
```

## Port States

| State | Description |
|-------|-------------|
| open | Port is accepting connections |
| closed | Port is reachable but not listening |
| filtered | No response (firewall/filtered) |
| open\|filtered | UDP port may be open or filtered |

## API Usage

```python
from ft_nmap import PortScanner, ScanType

scanner = PortScanner(timeout=1.0, threads=100)

# Scan host
result = scanner.scan_host("192.168.1.1", [22, 80, 443])

# Print results
print(scanner.format_results(result))

# Access port data
for port in result.ports:
    print(f"{port.port}: {port.state.value} ({port.service})")
```

## Common Ports

The scanner includes a database of common ports:
- 21 (FTP), 22 (SSH), 23 (Telnet)
- 25 (SMTP), 80 (HTTP), 443 (HTTPS)
- 3306 (MySQL), 5432 (PostgreSQL)
- And many more...

## Disclaimer

Only use this tool to scan networks and systems you have explicit permission to test. Unauthorized scanning may be illegal.

## Author

Implementation for 42 curriculum.
