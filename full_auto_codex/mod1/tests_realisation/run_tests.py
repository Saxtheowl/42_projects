#!/usr/bin/env python3
"""Utility script to execute the mod1 unit test suite."""

import os
import subprocess
import sys
from pathlib import Path


def main() -> int:
    project_root = Path(__file__).resolve().parent.parent
    env = dict(**os.environ)
    # Ensure the project root is part of PYTHONPATH
    env["PYTHONPATH"] = str(project_root) + ":" + env.get("PYTHONPATH", "")
    result = subprocess.run(
        [sys.executable, "-m", "unittest", "discover", "-s", "tests_realisation"],
        cwd=project_root,
        env=env,
        check=False,
    )
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
