"""Shared parsing and data structures for krpsim tools."""

from __future__ import annotations

import dataclasses
import re
from pathlib import Path
from typing import Dict, List, Tuple


@dataclasses.dataclass
class Process:
    name: str
    needs: Dict[str, int]
    results: Dict[str, int]
    duration: int


@dataclasses.dataclass
class SimulationConfig:
    stocks: Dict[str, int]
    processes: List[Process]
    optimize: List[str]


_PROCESS_RE = re.compile(
    r"^(?P<name>[\w-]+):\((?P<needs>[^)]*)\):\((?P<results>[^)]*)\):(?P<duration>\d+)$"
)

_PAIR_RE = re.compile(r"^\s*([\w-]+)\s*:\s*(\d+)\s*$")


class ParseError(RuntimeError):
    pass


def _parse_pairs(raw: str) -> Dict[str, int]:
    result: Dict[str, int] = {}
    raw = raw.strip()
    if not raw:
        return result
    for chunk in raw.split(";"):
        match = _PAIR_RE.match(chunk)
        if not match:
            raise ParseError(f"invalid resource specification: '{chunk}'")
        name, qty = match.group(1), int(match.group(2))
        result[name] = qty
    return result


def parse_config(path: str | Path) -> SimulationConfig:
    stocks: Dict[str, int] = {}
    processes: List[Process] = []
    optimize: List[str] = []

    with Path(path).open("r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("optimize:"):
                payload = line.split(":", 1)[1].strip()
                if payload.startswith("(") and payload.endswith(")"):
                    payload = payload[1:-1]
                optimize = [part.strip() for part in payload.split(";") if part.strip()]
                continue
            if ":" in line and line.count(":") == 1:
                name, qty = line.split(":", 1)
                name = name.strip()
                qty = qty.strip()
                if not qty.isdigit():
                    raise ParseError(f"invalid stock quantity: '{line}'")
                stocks[name] = int(qty)
                continue
            match = _PROCESS_RE.match(line)
            if not match:
                raise ParseError(f"invalid process line: '{line}'")
            needs = _parse_pairs(match.group("needs"))
            results = _parse_pairs(match.group("results"))
            duration = int(match.group("duration"))
            processes.append(Process(match.group("name"), needs, results, duration))
    if not processes:
        raise ParseError("configuration must declare at least one process")
    return SimulationConfig(stocks=stocks, processes=processes, optimize=optimize)


def clone_stocks(stocks: Dict[str, int]) -> Dict[str, int]:
    return dict(stocks)
