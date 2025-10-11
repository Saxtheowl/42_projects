#!/usr/bin/env python3
"""Run integration tests for the custom malloc implementation."""

import os
import subprocess
import sys
from pathlib import Path


def run(cmd, cwd):
    return subprocess.run(cmd, cwd=cwd, check=True)


def main() -> int:
    project_root = Path(__file__).resolve().parent.parent
    build_env = dict(os.environ)

    # Step 1: build the shared library
    run(["make"], cwd=project_root)

    # Step 2: compile the test harness
    tests_dir = project_root / "tests_realisation"
    test_binary = tests_dir / "test_allocator"
    run(
        [
            "cc",
            "-Wall",
            "-Wextra",
            "-Werror",
            str(tests_dir / "test_allocator.c"),
            "-ldl",
            "-o",
            str(test_binary),
        ],
        cwd=project_root,
    )

    # Step 3: run the test binary with our allocator preloaded
    env = dict(build_env)
    env["LD_PRELOAD"] = str(project_root / "libft_malloc.so")
    subprocess.run([str(test_binary)], cwd=tests_dir, check=True, env=env)

    print("All malloc tests passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
