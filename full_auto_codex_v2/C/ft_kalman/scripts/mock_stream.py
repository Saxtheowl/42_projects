#!/usr/bin/env python3
"""Mock IMU stream sender for local testing.

Sends UDP packets formatted as:
    dt ax ay az mx my mz
and prints the JSON responses returned by `kalman_demo --udp <port> <count>`.
"""
import socket
import sys
import time

def main() -> int:
    host = "127.0.0.1"
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 4242
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 5
    dt = 0.1
    accel = (0.05, 0.02, 0.01)

    samples = []
    for i in range(count):
        t = (i + 1) * dt
        mx = 1.0 * t + 0.1 * ((i % 2) * 2 - 1)
        my = 0.5 * t + 0.05 * ((i % 3) - 1)
        mz = 0.2 * t + 0.02 * ((i % 4) - 1.5)
        samples.append((dt, *accel, mx, my, mz))

    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.settimeout(1.0)
        for sample in samples:
            payload = " ".join(f"{v:.4f}" for v in sample)
            sock.sendto(payload.encode(), (host, port))
            try:
                data, _ = sock.recvfrom(2048)
                print(data.decode().strip())
            except socket.timeout:
                print("timeout waiting for response")
            time.sleep(dt)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
