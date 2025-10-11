"""Simulation heuristics for krpsim."""

from __future__ import annotations

import dataclasses
from typing import Dict, List, Optional, Sequence, Tuple

from .common import Process, SimulationConfig, clone_stocks


@dataclasses.dataclass
class ActiveProcess:
    process: Process
    end_time: int


class Simulation:
    def __init__(self, config: SimulationConfig, limit: int) -> None:
        self.config = config
        self.limit = limit
        self.time = 0
        self.stocks = clone_stocks(config.stocks)
        self.active: List[ActiveProcess] = []
        self.trace: List[Tuple[int, str]] = []

    def _collect_completed(self) -> None:
        completed = [ap for ap in self.active if ap.end_time <= self.time]
        if not completed:
            return
        self.active = [ap for ap in self.active if ap.end_time > self.time]
        for ap in completed:
            for name, qty in ap.process.results.items():
                self.stocks[name] = self.stocks.get(name, 0) + qty

    def _can_start(self, process: Process) -> bool:
        for name, qty in process.needs.items():
            if self.stocks.get(name, 0) < qty:
                return False
        return True

    def _start_process(self, process: Process) -> None:
        for name, qty in process.needs.items():
            self.stocks[name] -= qty
        self.active.append(ActiveProcess(process, self.time + process.duration))
        self.trace.append((self.time, process.name))

    def _priority(self, process: Process) -> Tuple[int, int, str]:
        optimize = self.config.optimize
        score = 0
        for resource in process.results:
            if resource in optimize:
                score -= 10
        if "time" in optimize:
            score -= process.duration
        return (score, process.duration, process.name)

    def run(self) -> None:
        while self.time <= self.limit:
            self._collect_completed()
            started = False
            startable = [p for p in self.config.processes if self._can_start(p)]
            if startable:
                startable.sort(key=self._priority)
                for process in startable:
                    while self._can_start(process):
                        self._start_process(process)
                        started = True
                if started:
                    continue
            if self.active:
                next_time = min(ap.end_time for ap in self.active)
                if next_time > self.limit:
                    self.time = next_time
                    self._collect_completed()
                    break
                if next_time <= self.time:
                    self.time += 1
                else:
                    self.time = next_time
                continue
            break

    def dump_state(self) -> List[str]:
        lines = ["Stock :"]
        for name in sorted(self.stocks):
            lines.append(f"{name} => {self.stocks[name]}")
        return lines
