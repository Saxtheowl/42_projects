#!/usr/bin/env python3
"""
ft_nmap - Network Scanner
Port scanning and service detection tool
"""

import sys
import socket
import struct
import time
import threading
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass, field
from enum import Enum
from concurrent.futures import ThreadPoolExecutor, as_completed


class ScanType(Enum):
    TCP_CONNECT = "tcp"
    SYN = "syn"
    UDP = "udp"
    FIN = "fin"
    NULL = "null"
    XMAS = "xmas"


class PortState(Enum):
    OPEN = "open"
    CLOSED = "closed"
    FILTERED = "filtered"
    OPEN_FILTERED = "open|filtered"


@dataclass
class ScanResult:
    """Result of a port scan."""
    port: int
    state: PortState
    service: str = ""
    banner: str = ""
    protocol: str = "tcp"


@dataclass
class HostScanResult:
    """Complete scan result for a host."""
    ip: str
    hostname: str = ""
    is_up: bool = False
    ports: List[ScanResult] = field(default_factory=list)
    scan_time: float = 0.0


# Common port -> service mapping
COMMON_PORTS = {
    20: "ftp-data",
    21: "ftp",
    22: "ssh",
    23: "telnet",
    25: "smtp",
    53: "dns",
    67: "dhcp",
    68: "dhcp",
    69: "tftp",
    80: "http",
    110: "pop3",
    119: "nntp",
    123: "ntp",
    135: "msrpc",
    137: "netbios-ns",
    138: "netbios-dgm",
    139: "netbios-ssn",
    143: "imap",
    161: "snmp",
    162: "snmptrap",
    389: "ldap",
    443: "https",
    445: "microsoft-ds",
    465: "smtps",
    514: "syslog",
    515: "printer",
    587: "submission",
    631: "ipp",
    636: "ldaps",
    993: "imaps",
    995: "pop3s",
    1080: "socks",
    1433: "mssql",
    1434: "mssql-m",
    1521: "oracle",
    1723: "pptp",
    2049: "nfs",
    3306: "mysql",
    3389: "rdp",
    5432: "postgresql",
    5900: "vnc",
    5901: "vnc-1",
    6379: "redis",
    8080: "http-proxy",
    8443: "https-alt",
    27017: "mongodb",
}


class PortScanner:
    """Network port scanner."""

    def __init__(self, timeout: float = 1.0, threads: int = 100):
        self.timeout = timeout
        self.threads = threads
        self.results: Dict[str, HostScanResult] = {}

    def resolve_host(self, target: str) -> Tuple[str, str]:
        """Resolve hostname to IP."""
        try:
            ip = socket.gethostbyname(target)
            try:
                hostname = socket.gethostbyaddr(ip)[0]
            except socket.herror:
                hostname = target if target != ip else ""
            return ip, hostname
        except socket.gaierror:
            return "", ""

    def ping_host(self, ip: str) -> bool:
        """Check if host is up using TCP ping to common ports."""
        test_ports = [80, 443, 22, 21, 25]

        for port in test_ports:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(0.5)
                result = sock.connect_ex((ip, port))
                sock.close()
                if result == 0:
                    return True
            except (socket.timeout, socket.error):
                pass

        return False

    def tcp_connect_scan(self, ip: str, port: int) -> ScanResult:
        """Perform TCP connect scan on a port."""
        service = COMMON_PORTS.get(port, "")
        banner = ""

        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            result = sock.connect_ex((ip, port))

            if result == 0:
                # Try to grab banner
                try:
                    sock.settimeout(0.5)
                    sock.send(b"HEAD / HTTP/1.0\r\n\r\n")
                    banner = sock.recv(256).decode('utf-8', errors='ignore').strip()
                    banner = banner[:50] if len(banner) > 50 else banner
                except Exception:
                    pass

                sock.close()
                return ScanResult(port, PortState.OPEN, service, banner)
            else:
                sock.close()
                return ScanResult(port, PortState.CLOSED, service)

        except socket.timeout:
            return ScanResult(port, PortState.FILTERED, service)
        except socket.error:
            return ScanResult(port, PortState.CLOSED, service)

    def udp_scan(self, ip: str, port: int) -> ScanResult:
        """Perform UDP scan on a port."""
        service = COMMON_PORTS.get(port, "")

        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.settimeout(self.timeout)

            # Send probe
            sock.sendto(b"\x00", (ip, port))

            try:
                data, _ = sock.recvfrom(1024)
                sock.close()
                return ScanResult(port, PortState.OPEN, service, protocol="udp")
            except socket.timeout:
                sock.close()
                return ScanResult(port, PortState.OPEN_FILTERED, service, protocol="udp")

        except socket.error:
            return ScanResult(port, PortState.CLOSED, service, protocol="udp")

    def scan_port(self, ip: str, port: int, scan_type: ScanType) -> ScanResult:
        """Scan a single port."""
        if scan_type == ScanType.TCP_CONNECT:
            return self.tcp_connect_scan(ip, port)
        elif scan_type == ScanType.UDP:
            return self.udp_scan(ip, port)
        else:
            # Default to TCP connect for unsupported scan types
            return self.tcp_connect_scan(ip, port)

    def scan_host(self, target: str, ports: List[int],
                  scan_type: ScanType = ScanType.TCP_CONNECT) -> HostScanResult:
        """Scan a host."""
        ip, hostname = self.resolve_host(target)

        if not ip:
            print(f"Failed to resolve: {target}")
            return HostScanResult(target, "", False)

        start_time = time.time()

        # Check if host is up
        is_up = self.ping_host(ip)

        result = HostScanResult(ip, hostname, is_up)

        if not is_up:
            print(f"Host {ip} appears to be down")
            return result

        print(f"Scanning {ip} ({hostname if hostname else 'no hostname'})...")

        # Scan ports using thread pool
        open_ports = []

        with ThreadPoolExecutor(max_workers=self.threads) as executor:
            futures = {
                executor.submit(self.scan_port, ip, port, scan_type): port
                for port in ports
            }

            for future in as_completed(futures):
                port_result = future.result()
                if port_result.state == PortState.OPEN:
                    open_ports.append(port_result)
                    result.ports.append(port_result)

        # Sort by port number
        result.ports.sort(key=lambda x: x.port)

        result.scan_time = time.time() - start_time
        self.results[ip] = result

        return result

    def scan_range(self, base_ip: str, start: int, end: int, ports: List[int],
                   scan_type: ScanType = ScanType.TCP_CONNECT) -> List[HostScanResult]:
        """Scan a range of IPs."""
        results = []

        parts = base_ip.split('.')
        if len(parts) != 4:
            print("Invalid IP format")
            return results

        base = '.'.join(parts[:3])

        for i in range(start, end + 1):
            ip = f"{base}.{i}"
            result = self.scan_host(ip, ports, scan_type)
            if result.is_up:
                results.append(result)

        return results

    def format_results(self, result: HostScanResult) -> str:
        """Format scan results for display."""
        lines = [
            "=" * 60,
            f"Scan Report for {result.ip}",
        ]

        if result.hostname:
            lines.append(f"Hostname: {result.hostname}")

        if not result.is_up:
            lines.append("Host appears to be down")
            lines.append("=" * 60)
            return "\n".join(lines)

        lines.append(f"Host is up")
        lines.append(f"Scanned in: {result.scan_time:.2f}s")
        lines.append("")

        if not result.ports:
            lines.append("No open ports found")
        else:
            lines.append(f"{'PORT':<10} {'STATE':<15} {'SERVICE':<15} {'BANNER'}")
            lines.append("-" * 60)

            for port in result.ports:
                port_str = f"{port.port}/{port.protocol}"
                lines.append(
                    f"{port_str:<10} {port.state.value:<15} {port.service:<15} {port.banner}"
                )

            lines.append("")
            lines.append(f"Open ports: {len(result.ports)}")

        lines.append("=" * 60)
        return "\n".join(lines)


def parse_ports(port_spec: str) -> List[int]:
    """Parse port specification like '22,80,443' or '1-1024'."""
    ports = []

    for part in port_spec.split(','):
        part = part.strip()
        if '-' in part:
            start, end = part.split('-')
            ports.extend(range(int(start), int(end) + 1))
        else:
            ports.append(int(part))

    return sorted(set(ports))


def get_common_ports() -> List[int]:
    """Get list of common ports."""
    return sorted(COMMON_PORTS.keys())


def get_top_ports(n: int = 100) -> List[int]:
    """Get top N most common ports."""
    top = [
        80, 23, 443, 21, 22, 25, 3389, 110, 445, 139,
        143, 53, 135, 3306, 8080, 1723, 111, 995, 993, 5900,
        1025, 587, 8888, 199, 1720, 465, 548, 113, 81, 6001,
        10000, 514, 5060, 179, 1026, 2000, 8443, 8000, 32768, 554,
        26, 1433, 49152, 2001, 515, 8008, 49154, 1027, 5666, 646,
        5000, 5631, 631, 49153, 8081, 2049, 88, 79, 5800, 106,
        2121, 1110, 49155, 6000, 513, 990, 5357, 427, 49156, 543,
        544, 5101, 144, 7, 389, 8009, 3128, 444, 9999, 5009,
        7070, 5190, 3000, 5432, 1900, 3986, 13, 1029, 9, 5051,
        6646, 49157, 1028, 873, 1755, 2717, 4899, 9100, 119, 37,
    ]
    return top[:n]


def run_demo():
    """Run demo scan."""
    print("ft_nmap - Network Scanner Demo")
    print("=" * 60)
    print()
    print("Note: This tool requires appropriate permissions to scan")
    print("networks. Only scan systems you have permission to test.")
    print()

    scanner = PortScanner(timeout=0.5, threads=50)

    # Demo: scan localhost
    print("Scanning localhost for common ports...")
    print()

    result = scanner.scan_host("127.0.0.1", get_top_ports(20))
    print(scanner.format_results(result))


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("ft_nmap - Network Port Scanner")
        print()
        print("Usage:")
        print("  python ft_nmap.py <target> [options]")
        print()
        print("Options:")
        print("  -p <ports>      Ports to scan (e.g., 22,80,443 or 1-1024)")
        print("  -sT             TCP connect scan (default)")
        print("  -sU             UDP scan")
        print("  --top <n>       Scan top N ports")
        print("  -t <threads>    Number of threads (default: 100)")
        print("  --timeout <s>   Timeout in seconds (default: 1.0)")
        print()
        print("Examples:")
        print("  python ft_nmap.py 192.168.1.1")
        print("  python ft_nmap.py example.com -p 22,80,443")
        print("  python ft_nmap.py 192.168.1.1 -p 1-1024")
        print("  python ft_nmap.py localhost --top 100")
        print()
        print("Run 'python ft_nmap.py --demo' for a demo")
        return

    if sys.argv[1] == '--demo':
        run_demo()
        return

    if sys.argv[1] == '--help':
        main()  # Show help
        return

    # Parse arguments
    target = sys.argv[1]
    ports = get_top_ports(100)  # Default
    scan_type = ScanType.TCP_CONNECT
    threads = 100
    timeout = 1.0

    i = 2
    while i < len(sys.argv):
        arg = sys.argv[i]

        if arg == '-p' and i + 1 < len(sys.argv):
            ports = parse_ports(sys.argv[i + 1])
            i += 2
        elif arg == '-sT':
            scan_type = ScanType.TCP_CONNECT
            i += 1
        elif arg == '-sU':
            scan_type = ScanType.UDP
            i += 1
        elif arg == '--top' and i + 1 < len(sys.argv):
            ports = get_top_ports(int(sys.argv[i + 1]))
            i += 2
        elif arg == '-t' and i + 1 < len(sys.argv):
            threads = int(sys.argv[i + 1])
            i += 2
        elif arg == '--timeout' and i + 1 < len(sys.argv):
            timeout = float(sys.argv[i + 1])
            i += 2
        else:
            i += 1

    # Create scanner and run
    scanner = PortScanner(timeout=timeout, threads=threads)

    print(f"Starting ft_nmap scan")
    print(f"Target: {target}")
    print(f"Ports: {len(ports)} ports")
    print(f"Scan type: {scan_type.value}")
    print()

    result = scanner.scan_host(target, ports, scan_type)
    print(scanner.format_results(result))


if __name__ == "__main__":
    main()
