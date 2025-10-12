#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BIN = ROOT / "computor_v2"


def build() -> None:
    subprocess.run(["make"], cwd=ROOT, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)


def run_session(commands):
    p = subprocess.Popen([str(BIN)], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    out, _ = p.communicate("\n".join(commands) + "\n")
    return out


def main() -> int:
    build()

    out = run_session(["z = 2 + 3i", "z * z", ""])
    assert "z = 2.000000 + 3.000000i" in out
    assert "-5.000000 + 12.000000i" in out

    out = run_session(["m = [[1,2];[3,4]]", "m * m", ""])
    assert "[[1.000000, 2.000000]; [3.000000, 4.000000]]" in out
    assert "[[7.000000, 10.000000]; [15.000000, 22.000000]]" in out

    out = run_session(["m = [[1,2];[3,4]]", "m + 1", "1 - m", ""])
    assert "[[2.000000, 3.000000]; [4.000000, 5.000000]]" in out
    assert "[[0.000000, -1.000000]; [-2.000000, -3.000000]]" in out

    out = run_session(["i", ""])
    assert "1.000000i" in out

    out = run_session(["a = sin(3)", "a", ""])
    assert "a =" in out and "a" in out

    print("All tests passed.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as exc:
        print(exc.stdout)
        raise
