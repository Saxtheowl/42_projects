#!/usr/bin/env python3
"""
Unit-like functional checks for Minishell builtins and core features.
"""

from __future__ import annotations

import pathlib
import subprocess
import sys
from dataclasses import dataclass
import os


PROJECT_ROOT = pathlib.Path(__file__).resolve().parents[1]
MINISHELL = PROJECT_ROOT / "minishell"


@dataclass
class TestCase:
    name: str
    script: str
    expected_stdout: str = ""
    expected_stderr: str = ""
    expected_status: int = 0


def run_case(case: TestCase) -> bool:
    result = subprocess.run(
        [str(MINISHELL)],
        input=case.script,
        text=True,
        capture_output=True,
        cwd=PROJECT_ROOT,
        env=os.environ.copy(),
    )
    ok = True
    if result.returncode != case.expected_status:
        print(f"[FAIL] {case.name}: status {result.returncode} != {case.expected_status}", file=sys.stderr)
        ok = False
    if result.stdout != case.expected_stdout:
        print(f"[FAIL] {case.name}: stdout mismatch", file=sys.stderr)
        print("Expected:", repr(case.expected_stdout), file=sys.stderr)
        print("Actual  :", repr(result.stdout), file=sys.stderr)
        ok = False
    if result.stderr != case.expected_stderr:
        print(f"[FAIL] {case.name}: stderr mismatch", file=sys.stderr)
        print("Expected:", repr(case.expected_stderr), file=sys.stderr)
        print("Actual  :", repr(result.stderr), file=sys.stderr)
        ok = False
    if ok:
        print(f"[PASS] {case.name}")
    return ok


def main() -> int:
    if not MINISHELL.exists():
        print("minishell binary not found; run `make` first.", file=sys.stderr)
        return 1

    cases = [
        TestCase(
            name="echo_basic",
            script="echo hello minishell\n",
            expected_stdout="hello minishell\n",
        ),
        TestCase(
            name="echo_n_flag",
            script="echo -nnn hi there\n",
            expected_stdout="hi there",
        ),
        TestCase(
            name="export_and_unset",
            script="export MINI=42\necho $MINI\nunset MINI\necho $MINI\n",
            expected_stdout="42\n\n",
        ),
        TestCase(
            name="export_append",
            script="export MINI=foo\nexport MINI+=bar\necho $MINI\n",
            expected_stdout="foobar\n",
        ),
        TestCase(
            name="exit_status",
            script="exit 7\n",
            expected_stdout="exit\n",
            expected_status=7,
        ),
        TestCase(
            name="tilde_home",
            script="export HOME=/tmp/minishell_home\necho ~\n",
            expected_stdout="/tmp/minishell_home\n",
        ),
    ]

    success = all(run_case(case) for case in cases)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
