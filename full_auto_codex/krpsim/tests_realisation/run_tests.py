#!/usr/bin/env python3
"""End-to-end tests for krpsim and krpsim_verif."""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def run(cmd, cwd):
    return subprocess.run(cmd, cwd=cwd, check=True, text=True, stdout=subprocess.PIPE)


def run_krpsim(config: Path, delay: int, trace_path: Path) -> None:
    proc = run(["./krpsim", str(config), str(delay)], ROOT)
    trace_lines = []
    for line in proc.stdout.splitlines():
        line = line.strip()
        if line and line.split(":", 1)[0].isdigit():
            trace_lines.append(line)
    trace_path.write_text("\n".join(trace_lines) + "\n", encoding="utf-8")


def verify(config: Path, trace: Path) -> None:
    run(["./krpsim_verif", str(config), str(trace)], ROOT)


def main() -> int:
    consuming_trace = ROOT / "tests_realisation" / "sample_consuming.trace"
    endless_trace = ROOT / "tests_realisation" / "sample_endless.trace"

    run_krpsim(ROOT / "configs" / "sample_consuming.cfg", 120, consuming_trace)
    verify(ROOT / "configs" / "sample_consuming.cfg", consuming_trace)

    run_krpsim(ROOT / "configs" / "sample_endless.cfg", 100, endless_trace)
    verify(ROOT / "configs" / "sample_endless.cfg", endless_trace)

    print("krpsim tests passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
