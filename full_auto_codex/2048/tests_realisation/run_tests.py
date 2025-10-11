#!/usr/bin/env python3

import subprocess
from pathlib import Path
import sys


def main() -> int:
    tests_dir = Path(__file__).resolve().parent
    project_root = tests_dir.parent
    binary_path = tests_dir / "test_logic"

    compile_cmd = [
        "cc",
        "-Wall",
        "-Wextra",
        "-Werror",
        "-I",
        str(project_root / "include"),
        str(project_root / "src/game.c"),
        str(tests_dir / "test_logic.c"),
        "-o",
        str(binary_path),
    ]

    try:
        subprocess.run(compile_cmd, check=True, cwd=tests_dir)
        subprocess.run([str(binary_path)], check=True, cwd=tests_dir)
    except subprocess.CalledProcessError as exc:
        print(f"[tests] command failed: {exc}", file=sys.stderr)
        return 1

    print("All logic tests passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
