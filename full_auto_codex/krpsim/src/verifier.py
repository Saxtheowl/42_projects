"""Verification logic for krpsim traces."""

from __future__ import annotations

from typing import Dict, Iterable, List, Tuple

from .common import Process, SimulationConfig, clone_stocks


class VerificationError(RuntimeError):
    def __init__(self, message: str, cycle: int | None = None, process: str | None = None):
        super().__init__(message)
        self.cycle = cycle
        self.process = process


def load_trace(path: str) -> List[Tuple[int, str]]:
    trace: List[Tuple[int, str]] = []
    with open(path, "r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line or line.startswith("#"):
                continue
            if ":" not in line:
                raise VerificationError(f"invalid trace line: {line}")
            time_str, name = line.split(":", 1)
            if not time_str.isdigit():
                raise VerificationError(f"invalid time: {line}")
            trace.append((int(time_str), name.strip()))
    return trace


def verify_trace(config: SimulationConfig, trace: List[Tuple[int, str]]) -> Tuple[Dict[str, int], int]:
    stocks = clone_stocks(config.stocks)
    processes = {proc.name: proc for proc in config.processes}
    current_time = 0
    finished_events: List[Tuple[int, Process]] = []

    for time, name in trace:
        if name not in processes:
            raise VerificationError(f"unknown process {name}", cycle=time, process=name)
        if time < current_time:
            raise VerificationError("trace times must be non-decreasing", cycle=time, process=name)
        finished_events.sort(key=lambda item: item[0])
        while finished_events and finished_events[0][0] <= time:
            finish_time, proc = finished_events.pop(0)
            for res_name, qty in proc.results.items():
                stocks[res_name] = stocks.get(res_name, 0) + qty
            current_time = max(current_time, finish_time)
        proc = processes[name]
        for need, qty in proc.needs.items():
            if stocks.get(need, 0) < qty:
                raise VerificationError(
                    f"insufficient stock '{need}'", cycle=time, process=name
                )
        for need, qty in proc.needs.items():
            stocks[need] -= qty
        finished_events.append((time + proc.duration, proc))
        current_time = time
    # Flush remaining completions
    finished_events.sort(key=lambda item: item[0])
    while finished_events:
        finish_time, proc = finished_events.pop(0)
        for res_name, qty in proc.results.items():
            stocks[res_name] = stocks.get(res_name, 0) + qty
        current_time = max(current_time, finish_time)
    return stocks, current_time
