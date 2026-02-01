#!/usr/bin/env python3
"""
Net Practice - Network Configuration Tool
42 School Project - Networking

A tool to practice and validate IP addressing, subnetting, and routing.
"""

import sys
import re
from dataclasses import dataclass
from typing import List, Tuple, Optional


# =============================================================================
# IP Address Utilities
# =============================================================================

@dataclass
class IPAddress:
    """Represents an IPv4 address."""
    octets: Tuple[int, int, int, int]

    def __init__(self, address: str):
        parts = address.strip().split('.')
        if len(parts) != 4:
            raise ValueError(f"Invalid IP address format: {address}")
        self.octets = tuple(int(p) for p in parts)
        for o in self.octets:
            if not 0 <= o <= 255:
                raise ValueError(f"Octet out of range: {o}")

    def __str__(self):
        return '.'.join(str(o) for o in self.octets)

    def __int__(self):
        return (self.octets[0] << 24) + (self.octets[1] << 16) + \
               (self.octets[2] << 8) + self.octets[3]

    @classmethod
    def from_int(cls, value: int):
        return cls(f"{(value >> 24) & 0xFF}.{(value >> 16) & 0xFF}."
                  f"{(value >> 8) & 0xFF}.{value & 0xFF}")

    def is_private(self) -> bool:
        """Check if this is a private IP address."""
        # 10.0.0.0/8
        if self.octets[0] == 10:
            return True
        # 172.16.0.0/12
        if self.octets[0] == 172 and 16 <= self.octets[1] <= 31:
            return True
        # 192.168.0.0/16
        if self.octets[0] == 192 and self.octets[1] == 168:
            return True
        return False

    def is_loopback(self) -> bool:
        """Check if this is a loopback address."""
        return self.octets[0] == 127

    def is_broadcast(self, mask: 'SubnetMask') -> bool:
        """Check if this is a broadcast address for the given mask."""
        network = self.get_network(mask)
        broadcast = network.get_broadcast(mask)
        return int(self) == int(broadcast)

    def is_network(self, mask: 'SubnetMask') -> bool:
        """Check if this is a network address."""
        return (int(self) & int(mask)) == int(self)

    def get_network(self, mask: 'SubnetMask') -> 'IPAddress':
        """Get the network address for this IP with given mask."""
        return IPAddress.from_int(int(self) & int(mask))

    def get_broadcast(self, mask: 'SubnetMask') -> 'IPAddress':
        """Get the broadcast address (when this is a network address)."""
        wildcard = ~int(mask) & 0xFFFFFFFF
        return IPAddress.from_int(int(self) | wildcard)

    def in_same_network(self, other: 'IPAddress', mask: 'SubnetMask') -> bool:
        """Check if two IPs are in the same network."""
        return self.get_network(mask).octets == other.get_network(mask).octets


@dataclass
class SubnetMask:
    """Represents a subnet mask."""
    octets: Tuple[int, int, int, int]

    def __init__(self, mask: str):
        # Handle CIDR notation
        if mask.startswith('/') or mask.isdigit():
            cidr = int(mask.lstrip('/'))
            if not 0 <= cidr <= 32:
                raise ValueError(f"Invalid CIDR: {cidr}")
            binary = '1' * cidr + '0' * (32 - cidr)
            self.octets = (
                int(binary[0:8], 2),
                int(binary[8:16], 2),
                int(binary[16:24], 2),
                int(binary[24:32], 2)
            )
        else:
            parts = mask.strip().split('.')
            if len(parts) != 4:
                raise ValueError(f"Invalid mask format: {mask}")
            self.octets = tuple(int(p) for p in parts)
            # Validate mask is contiguous
            if not self.is_valid():
                raise ValueError(f"Invalid subnet mask: {mask}")

    def __str__(self):
        return '.'.join(str(o) for o in self.octets)

    def __int__(self):
        return (self.octets[0] << 24) + (self.octets[1] << 16) + \
               (self.octets[2] << 8) + self.octets[3]

    def is_valid(self) -> bool:
        """Check if mask bits are contiguous."""
        binary = bin(int(self))[2:].zfill(32)
        return '01' not in binary  # Should be all 1s followed by all 0s

    def to_cidr(self) -> int:
        """Convert mask to CIDR notation."""
        return bin(int(self)).count('1')

    def host_count(self) -> int:
        """Number of usable host addresses."""
        cidr = self.to_cidr()
        if cidr >= 31:
            return 2 ** (32 - cidr)
        return 2 ** (32 - cidr) - 2  # Subtract network and broadcast


# =============================================================================
# Network Interface
# =============================================================================

@dataclass
class Interface:
    """Represents a network interface."""
    name: str
    ip: Optional[IPAddress] = None
    mask: Optional[SubnetMask] = None

    def is_configured(self) -> bool:
        return self.ip is not None and self.mask is not None

    def get_network(self) -> Optional[IPAddress]:
        if self.is_configured():
            return self.ip.get_network(self.mask)
        return None

    def get_broadcast(self) -> Optional[IPAddress]:
        if self.is_configured():
            return self.ip.get_network(self.mask).get_broadcast(self.mask)
        return None

    def validate(self) -> List[str]:
        """Validate interface configuration, return list of errors."""
        errors = []
        if not self.is_configured():
            errors.append(f"{self.name}: Not configured")
            return errors

        if self.ip.is_loopback():
            errors.append(f"{self.name}: Cannot use loopback address")
        if self.ip.is_network(self.mask):
            errors.append(f"{self.name}: Cannot use network address")
        if self.ip.is_broadcast(self.mask):
            errors.append(f"{self.name}: Cannot use broadcast address")

        return errors


# =============================================================================
# Route
# =============================================================================

@dataclass
class Route:
    """Represents a routing table entry."""
    destination: IPAddress  # Network address
    mask: SubnetMask
    gateway: IPAddress
    interface: str

    def matches(self, ip: IPAddress) -> bool:
        """Check if this route matches the destination IP."""
        return ip.get_network(self.mask).octets == self.destination.octets

    def __str__(self):
        return f"{self.destination}/{self.mask.to_cidr()} via {self.gateway}"


# =============================================================================
# Network Device
# =============================================================================

class Device:
    """Represents a network device (host, router, switch)."""

    def __init__(self, name: str, device_type: str = "host"):
        self.name = name
        self.device_type = device_type
        self.interfaces: List[Interface] = []
        self.routes: List[Route] = []

    def add_interface(self, name: str, ip: str = None, mask: str = None):
        """Add a network interface."""
        iface = Interface(name)
        if ip:
            iface.ip = IPAddress(ip)
        if mask:
            iface.mask = SubnetMask(mask)
        self.interfaces.append(iface)
        return iface

    def add_route(self, dest: str, mask: str, gateway: str, interface: str):
        """Add a routing table entry."""
        route = Route(
            IPAddress(dest),
            SubnetMask(mask),
            IPAddress(gateway),
            interface
        )
        self.routes.append(route)
        return route

    def get_interface(self, name: str) -> Optional[Interface]:
        for iface in self.interfaces:
            if iface.name == name:
                return iface
        return None

    def find_route(self, destination: IPAddress) -> Optional[Route]:
        """Find the best route for a destination."""
        best_route = None
        best_cidr = -1

        for route in self.routes:
            if route.matches(destination):
                cidr = route.mask.to_cidr()
                if cidr > best_cidr:
                    best_route = route
                    best_cidr = cidr

        return best_route

    def validate(self) -> List[str]:
        """Validate all configurations."""
        errors = []

        # Validate interfaces
        for iface in self.interfaces:
            errors.extend(iface.validate())

        # Validate routes
        for route in self.routes:
            # Check gateway is reachable
            reachable = False
            for iface in self.interfaces:
                if iface.is_configured() and \
                   route.gateway.in_same_network(iface.ip, iface.mask):
                    reachable = True
                    break
            if not reachable:
                errors.append(f"Route {route}: Gateway not directly reachable")

        return errors


# =============================================================================
# Network Topology
# =============================================================================

class Network:
    """Represents a network topology."""

    def __init__(self):
        self.devices: List[Device] = []
        self.connections: List[Tuple[str, str, str, str]] = []  # (dev1, if1, dev2, if2)

    def add_device(self, name: str, device_type: str = "host") -> Device:
        device = Device(name, device_type)
        self.devices.append(device)
        return device

    def get_device(self, name: str) -> Optional[Device]:
        for dev in self.devices:
            if dev.name == name:
                return dev
        return None

    def connect(self, dev1: str, if1: str, dev2: str, if2: str):
        """Connect two interfaces."""
        self.connections.append((dev1, if1, dev2, if2))

    def validate(self) -> List[str]:
        """Validate entire network configuration."""
        errors = []

        # Validate each device
        for device in self.devices:
            dev_errors = device.validate()
            for err in dev_errors:
                errors.append(f"[{device.name}] {err}")

        # Validate connections (same network)
        for dev1_name, if1_name, dev2_name, if2_name in self.connections:
            dev1 = self.get_device(dev1_name)
            dev2 = self.get_device(dev2_name)
            if not dev1 or not dev2:
                continue

            if1 = dev1.get_interface(if1_name)
            if2 = dev2.get_interface(if2_name)

            if if1 and if2 and if1.is_configured() and if2.is_configured():
                if not if1.ip.in_same_network(if2.ip, if1.mask):
                    errors.append(
                        f"Connection {dev1_name}.{if1_name} <-> {dev2_name}.{if2_name}: "
                        f"Different networks ({if1.get_network()} vs {if2.get_network()})"
                    )
                if if1.mask.octets != if2.mask.octets:
                    errors.append(
                        f"Connection {dev1_name}.{if1_name} <-> {dev2_name}.{if2_name}: "
                        f"Different masks ({if1.mask} vs {if2.mask})"
                    )

        return errors

    def test_connectivity(self, src_dev: str, dst_ip: str) -> Tuple[bool, List[str]]:
        """Test if source device can reach destination IP."""
        path = []
        device = self.get_device(src_dev)
        destination = IPAddress(dst_ip)

        if not device:
            return False, [f"Source device {src_dev} not found"]

        # Check if directly connected
        for iface in device.interfaces:
            if iface.is_configured() and destination.in_same_network(iface.ip, iface.mask):
                path.append(f"{device.name}.{iface.name} -> {dst_ip} (direct)")
                return True, path

        # Need routing
        route = device.find_route(destination)
        if not route:
            path.append(f"{device.name}: No route to {dst_ip}")
            return False, path

        path.append(f"{device.name} -> {route.gateway} via {route.interface}")

        # Find next hop device
        for conn in self.connections:
            if conn[0] == device.name and conn[1] == route.interface:
                next_dev = self.get_device(conn[2])
                if next_dev:
                    success, next_path = self.test_connectivity(conn[2], dst_ip)
                    path.extend(next_path)
                    return success, path

        return False, path + ["Next hop not found"]


# =============================================================================
# Subnet Calculator
# =============================================================================

def calculate_subnet(ip_cidr: str):
    """Calculate subnet information from IP/CIDR notation."""
    parts = ip_cidr.split('/')
    ip = IPAddress(parts[0])
    mask = SubnetMask(parts[1] if len(parts) > 1 else '24')

    network = ip.get_network(mask)
    broadcast = network.get_broadcast(mask)
    first_host = IPAddress.from_int(int(network) + 1)
    last_host = IPAddress.from_int(int(broadcast) - 1)

    print(f"\nSubnet Calculator: {ip_cidr}")
    print("=" * 40)
    print(f"IP Address:      {ip}")
    print(f"Subnet Mask:     {mask}")
    print(f"CIDR Notation:   /{mask.to_cidr()}")
    print(f"Network Address: {network}")
    print(f"Broadcast:       {broadcast}")
    print(f"First Host:      {first_host}")
    print(f"Last Host:       {last_host}")
    print(f"Total Hosts:     {mask.host_count()}")
    print(f"IP Class:        {get_class(ip)}")
    print(f"Private:         {'Yes' if ip.is_private() else 'No'}")


def get_class(ip: IPAddress) -> str:
    """Determine IP address class."""
    first = ip.octets[0]
    if first < 128:
        return "A"
    elif first < 192:
        return "B"
    elif first < 224:
        return "C"
    elif first < 240:
        return "D (Multicast)"
    else:
        return "E (Reserved)"


def subnet_exercise():
    """Interactive subnet exercise."""
    import random

    # Generate random IP and mask
    first = random.choice([10, 172, 192])
    if first == 172:
        second = random.randint(16, 31)
    elif first == 192:
        second = 168
    else:
        second = random.randint(0, 255)
    third = random.randint(0, 255)
    fourth = random.randint(1, 254)
    cidr = random.randint(16, 28)

    ip = IPAddress(f"{first}.{second}.{third}.{fourth}")
    mask = SubnetMask(f"/{cidr}")

    print("\n" + "=" * 50)
    print("SUBNET EXERCISE")
    print("=" * 50)
    print(f"\nGiven IP: {ip}/{cidr}")
    print("\nCalculate:")
    print("1. Network address")
    print("2. Broadcast address")
    print("3. Number of usable hosts")
    print("4. First usable IP")
    print("5. Last usable IP")

    input("\nPress Enter to see answers...")

    network = ip.get_network(mask)
    broadcast = network.get_broadcast(mask)

    print(f"\n1. Network:    {network}")
    print(f"2. Broadcast:  {broadcast}")
    print(f"3. Hosts:      {mask.host_count()}")
    print(f"4. First IP:   {IPAddress.from_int(int(network) + 1)}")
    print(f"5. Last IP:    {IPAddress.from_int(int(broadcast) - 1)}")


# =============================================================================
# Example Network
# =============================================================================

def create_example_network() -> Network:
    """Create an example network topology."""
    net = Network()

    # Client
    client = net.add_device("Client", "host")
    client.add_interface("eth0", "192.168.1.10", "255.255.255.0")
    client.add_route("0.0.0.0", "0.0.0.0", "192.168.1.1", "eth0")

    # Router
    router = net.add_device("Router", "router")
    router.add_interface("eth0", "192.168.1.1", "255.255.255.0")
    router.add_interface("eth1", "10.0.0.1", "255.255.255.0")

    # Server
    server = net.add_device("Server", "host")
    server.add_interface("eth0", "10.0.0.10", "255.255.255.0")
    server.add_route("0.0.0.0", "0.0.0.0", "10.0.0.1", "eth0")

    # Connections
    net.connect("Client", "eth0", "Router", "eth0")
    net.connect("Router", "eth1", "Server", "eth0")

    return net


def interactive_mode():
    """Interactive network configuration mode."""
    net = Network()

    print("\nInteractive Network Configuration")
    print("Commands: device, interface, route, connect, validate, test, show, quit")

    while True:
        try:
            cmd = input("\n> ").strip().lower().split()
            if not cmd:
                continue

            if cmd[0] == "quit":
                break

            elif cmd[0] == "device":
                if len(cmd) >= 2:
                    dtype = cmd[2] if len(cmd) > 2 else "host"
                    net.add_device(cmd[1], dtype)
                    print(f"Added {dtype}: {cmd[1]}")
                else:
                    print("Usage: device <name> [type]")

            elif cmd[0] == "interface":
                if len(cmd) >= 5:
                    dev = net.get_device(cmd[1])
                    if dev:
                        dev.add_interface(cmd[2], cmd[3], cmd[4])
                        print(f"Added interface {cmd[2]} to {cmd[1]}")
                    else:
                        print(f"Device {cmd[1]} not found")
                else:
                    print("Usage: interface <device> <name> <ip> <mask>")

            elif cmd[0] == "route":
                if len(cmd) >= 6:
                    dev = net.get_device(cmd[1])
                    if dev:
                        dev.add_route(cmd[2], cmd[3], cmd[4], cmd[5])
                        print(f"Added route to {cmd[1]}")
                    else:
                        print(f"Device {cmd[1]} not found")
                else:
                    print("Usage: route <device> <dest> <mask> <gateway> <interface>")

            elif cmd[0] == "connect":
                if len(cmd) >= 5:
                    net.connect(cmd[1], cmd[2], cmd[3], cmd[4])
                    print(f"Connected {cmd[1]}.{cmd[2]} <-> {cmd[3]}.{cmd[4]}")
                else:
                    print("Usage: connect <dev1> <if1> <dev2> <if2>")

            elif cmd[0] == "validate":
                errors = net.validate()
                if errors:
                    print("Validation errors:")
                    for err in errors:
                        print(f"  - {err}")
                else:
                    print("Network configuration is valid!")

            elif cmd[0] == "test":
                if len(cmd) >= 3:
                    success, path = net.test_connectivity(cmd[1], cmd[2])
                    print("Path:")
                    for step in path:
                        print(f"  {step}")
                    print(f"Result: {'Reachable' if success else 'Unreachable'}")
                else:
                    print("Usage: test <source_device> <destination_ip>")

            elif cmd[0] == "show":
                for dev in net.devices:
                    print(f"\n{dev.name} ({dev.device_type}):")
                    for iface in dev.interfaces:
                        if iface.is_configured():
                            print(f"  {iface.name}: {iface.ip}/{iface.mask.to_cidr()}")
                    for route in dev.routes:
                        print(f"  Route: {route}")

            else:
                print("Unknown command")

        except Exception as e:
            print(f"Error: {e}")


# =============================================================================
# Main
# =============================================================================

def main():
    print("Net Practice - Network Configuration Tool")
    print("=" * 50)

    if len(sys.argv) < 2 or '--help' in sys.argv:
        print("\nUsage:")
        print("  python net_practice.py calc <ip/cidr>  - Calculate subnet")
        print("  python net_practice.py exercise        - Random subnet exercise")
        print("  python net_practice.py example         - Show example network")
        print("  python net_practice.py interactive     - Interactive mode")
        print("\nExamples:")
        print("  python net_practice.py calc 192.168.1.100/24")
        print("  python net_practice.py calc 10.0.0.50/16")
        return

    cmd = sys.argv[1]

    if cmd == "calc" and len(sys.argv) > 2:
        calculate_subnet(sys.argv[2])

    elif cmd == "exercise":
        subnet_exercise()

    elif cmd == "example":
        net = create_example_network()
        print("\nExample Network Topology:")
        print("-" * 40)
        print("Client (192.168.1.10) --> Router --> Server (10.0.0.10)")
        print()

        for dev in net.devices:
            print(f"{dev.name} ({dev.device_type}):")
            for iface in dev.interfaces:
                if iface.is_configured():
                    print(f"  {iface.name}: {iface.ip}/{iface.mask.to_cidr()}")
                    print(f"    Network: {iface.get_network()}")
            for route in dev.routes:
                print(f"  Route: {route}")
            print()

        print("Validation:")
        errors = net.validate()
        if errors:
            for err in errors:
                print(f"  ERROR: {err}")
        else:
            print("  All configurations valid!")

        print("\nConnectivity Test: Client -> 10.0.0.10")
        success, path = net.test_connectivity("Client", "10.0.0.10")
        for step in path:
            print(f"  {step}")
        print(f"  Result: {'Reachable' if success else 'Unreachable'}")

    elif cmd == "interactive":
        interactive_mode()

    else:
        print(f"Unknown command: {cmd}")


if __name__ == "__main__":
    main()
