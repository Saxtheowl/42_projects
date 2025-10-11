#!/usr/bin/env python3
"""Smoke tests for ft_nm et ft_otool."""

import subprocess
import sys
from pathlib import Path


def run(cmd, cwd):
    return subprocess.run(cmd, cwd=cwd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def main() -> int:
    project_root = Path(__file__).resolve().parent.parent
    build_dir = project_root / "tests_realisation"

    # Build tools
    run(["make"], cwd=project_root)

    sample_c = build_dir / "sample.c"
    sample_c.write_text(
        """
        #include <stdio.h>\n
        static int helper(void) { return 21; }\n
        int main(void) { return helper() * 2; }\n
        """
    )

    sample_bin = build_dir / "sample"
    run(["cc", str(sample_c), "-o", str(sample_bin)], cwd=project_root)

    nm_res = run([str(project_root / "ft_nm"), str(sample_bin)], cwd=project_root)
    if " main" not in nm_res.stdout:
        print("[tests] main symbol not found in ft_nm output", file=sys.stderr)
        return 1

    otool_res = run([str(project_root / "ft_otool"), str(sample_bin)], cwd=project_root)
    lines = [line for line in otool_res.stdout.splitlines() if line and line[0].isdigit()]
    if not lines:
        print("[tests] ft_otool did not output text section bytes", file=sys.stderr)
        return 1

    print("ft_nm/ft_otool smoke tests passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
