#!/usr/bin/env python3
from pathlib import Path
import argparse

def main():
    parser = argparse.ArgumentParser(description='Generate default ft_services config')
    parser.add_argument('--output', default='tests/env/ft_services.conf')
    args = parser.parse_args()
    path = Path(args.output)
    path.parent.mkdir(parents=True, exist_ok=True)
    content = 'port=4242\nbacklog=16\nlog_path=tests/env/log/ft_services.log\n'
    path.write_text(content)
    print(f'Wrote {path}')

if __name__ == '__main__':
    main()
