#!/usr/bin/env python3
from pathlib import Path
import argparse
import re

pattern = re.compile(r"^(port|backlog|log_path)=(.*)$")


def main():
    parser = argparse.ArgumentParser(description='validate ft_services config')
    parser.add_argument('--config', default='/etc/ft_services.conf')
    args = parser.parse_args()
    path = Path(args.config)
    if not path.exists():
        raise SystemExit(f"missing config {path}")
    port = backlog = None
    for line in path.read_text().splitlines():
        m = pattern.match(line.strip())
        if not m:
            continue
        key, val = m.groups()
        if key == 'port':
            port = int(val)
        elif key == 'backlog':
            backlog = int(val)
    if not (1024 <= (port or 0) <= 65535):
        raise SystemExit('port out of range')
    if backlog is not None and backlog <= 0:
        raise SystemExit('invalid backlog')
    print('config OK')


if __name__ == '__main__':
    main()
