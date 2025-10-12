#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def build() -> None:
    subprocess.run(["make"], cwd=ROOT, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)


def run_case(equation: str) -> str:
    result = subprocess.run([str(ROOT / "computor"), equation], cwd=ROOT, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return result.stdout


def main() -> int:
    build()

    out = run_case("5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0")
    assert "Polynomial degree: 2" in out
    assert "Discriminant is strictly positive" in out

    out = run_case("5 * X^0 + 4 * X^1 = 4 * X^0")
    assert "Polynomial degree: 1" in out
    assert "-0.250000" in out

    out = run_case("5 * X^0 = 5 * X^0")
    assert "Polynomial degree: 0" in out
    assert "All real numbers" in out

    print("All tests passed.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as exc:
        print(exc.stdout)
        raise
