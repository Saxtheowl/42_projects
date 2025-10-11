"""Entry point for krpsim_verif."""

from __future__ import annotations

import argparse

from .common import ParseError, parse_config
from .verifier import VerificationError, load_trace, verify_trace


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="krpsim verifier")
    parser.add_argument("config", help="configuration file path")
    parser.add_argument("trace", help="trace file to verify")
    return parser


def main(argv=None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        config = parse_config(args.config)
        trace = load_trace(args.trace)
        stocks, last_time = verify_trace(config, trace)
    except (OSError, ParseError, VerificationError) as exc:
        print(f"krpsim_verif: {exc}")
        if isinstance(exc, VerificationError) and exc.cycle is not None:
            print(f"Failure at cycle {exc.cycle}, process {exc.process}")
        return 1
    print(f"Trace valid up to t={last_time}")
    for name in sorted(stocks):
        print(f"{name} => {stocks[name]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
