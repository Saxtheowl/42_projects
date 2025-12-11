#!/usr/bin/env python3
import argparse
import socket


def load_config(path):
    config = {}
    with open(path) as f:
        for line in f:
            if '=' in line:
                key, value = line.split('=', 1)
                config[key.strip()] = value.strip()
    return config


def main():
    parser = argparse.ArgumentParser(description='Envoyer une série de commandes au service ft_services.')
    parser.add_argument('--config', '-c', default='tests/env/ft_services.conf')
    parser.add_argument('--commands', '-x', nargs='+', default=['STATUS', 'COUNT'])
    parser.add_argument('--timeout', '-t', type=float, default=5.0)
    args = parser.parse_args()

    cfg = load_config(args.config)
    port = int(cfg.get('port', '4242'))
    host = cfg.get('host', '127.0.0.1')

    with socket.create_connection((host, port), timeout=args.timeout) as sock:
        for cmd in args.commands:
            sock.sendall((cmd + '\n').encode('utf-8'))
            response = sock.recv(1024).decode('utf-8').strip()
            print(f"> {cmd}\n< {response}\n")


if __name__ == '__main__':
    main()
