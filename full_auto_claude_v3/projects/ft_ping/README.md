# ft_ping

A reimplementation of the ping command using ICMP protocol.

## Description

This project recreates the ping command that tests network connectivity by sending ICMP Echo Request packets and receiving ICMP Echo Reply packets. It measures round-trip time (RTT) and packet loss.

## Features

- Send ICMP Echo Request packets
- Receive ICMP Echo Reply packets
- Calculate RTT statistics (min/avg/max/mdev)
- Support for hostnames and IP addresses
- Verbose mode for detailed output

## Options

| Option | Description |
|--------|-------------|
| `-v` | Verbose output (show errors and packet details) |
| `-h` | Print help message |

## Compilation

```bash
make
```

## Usage

**Note**: This program requires root privileges to create raw sockets.

```bash
sudo ./ft_ping google.com
sudo ./ft_ping -v 8.8.8.8
```

### Example Output

```
PING google.com (142.250.185.206) 56(84) bytes of data.
64 bytes from 142.250.185.206: icmp_seq=1 ttl=117 time=12.345 ms
64 bytes from 142.250.185.206: icmp_seq=2 ttl=117 time=11.234 ms
64 bytes from 142.250.185.206: icmp_seq=3 ttl=117 time=10.567 ms
^C
--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss
rtt min/avg/max/mdev = 10.567/11.382/12.345/0.724 ms
```

## Technical Details

### ICMP Protocol

- **Echo Request** (Type 8, Code 0): Sent to destination
- **Echo Reply** (Type 0, Code 0): Received from destination
- Uses 64-byte packets (8-byte ICMP header + 56-byte payload)

### Allowed Functions

- `getpid`, `getuid`
- `getaddrinfo`, `inet_ntop`, `inet_pton`
- `gettimeofday`
- `socket`, `setsockopt`, `sendto`, `recvmsg`
- `signal`, `alarm`, `exit`
- `printf` family

### Forbidden Functions

- `fcntl`, `poll`, `ppoll`

## Signal Handling

- **SIGINT** (Ctrl+C): Stop ping and print statistics
- **SIGALRM**: Trigger next ping (1-second interval)

## Requirements

- Linux system with kernel > 3.14
- Root privileges (for raw socket creation)

## Author

Implementation for 42 curriculum.
