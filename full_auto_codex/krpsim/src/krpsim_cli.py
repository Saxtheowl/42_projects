"""Entry point for krpsim (simulator)."""

from __future__ import annotations

import argparse
from typing import List

from .common import ParseError, parse_config
from .simulator import Simulation


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="krpsim simulator")
    parser.add_argument("config", help="configuration file path")
    parser.add_argument("delay", type=int, help="simulation time limit")
    return parser


def main(argv: List[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        config = parse_config(args.config)
    except (OSError, ParseError) as exc:
        print(f"krpsim: error loading config: {exc}")
        return 1
    sim = Simulation(config, args.delay)
    sim.run()
    print(f"Simulated until t={sim.time}")
    for time, name in sim.trace:
        print(f"{time}:{name}")
    for line in sim.dump_state():
        print(line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
