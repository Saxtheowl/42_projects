#!/usr/bin/env python3
"""
End-to-end comparisons between minishell and bash for representative scenarios.
"""

from __future__ import annotations

import os
import pathlib
import subprocess
import sys
from dataclasses import dataclass
from typing import Tuple


PROJECT_ROOT = pathlib.Path(__file__).resolve().parents[1]
MINISHELL = PROJECT_ROOT / "minishell"
BASH_CMD = ["bash", "--noprofile", "--norc"]


@dataclass
class Scenario:
    name: str
    script: str


def run_shell(command: list[str], script: str) -> Tuple[int, str, str]:
    completed = subprocess.run(
        command,
        input=script,
        text=True,
        capture_output=True,
        cwd=PROJECT_ROOT,
        env=os.environ.copy(),
    )
    return completed.returncode, completed.stdout, completed.stderr


def compare_with_bash(scenario: Scenario) -> bool:
    ms_status, ms_stdout, ms_stderr = run_shell([str(MINISHELL)], scenario.script)
    bash_status, bash_stdout, bash_stderr = run_shell(BASH_CMD, scenario.script)

    ok = True
    if ms_status != bash_status:
        print(f"[FAIL] {scenario.name}: exit status {ms_status} != {bash_status}", file=sys.stderr)
        ok = False
    if ms_stdout != bash_stdout:
        print(f"[FAIL] {scenario.name}: stdout differs", file=sys.stderr)
        print("--- minishell stdout ---", file=sys.stderr)
        print(repr(ms_stdout), file=sys.stderr)
        print("--- bash stdout ---", file=sys.stderr)
        print(repr(bash_stdout), file=sys.stderr)
        ok = False
    if ms_stderr != bash_stderr:
        print(f"[FAIL] {scenario.name}: stderr differs", file=sys.stderr)
        print("--- minishell stderr ---", file=sys.stderr)
        print(repr(ms_stderr), file=sys.stderr)
        print("--- bash stderr ---", file=sys.stderr)
        print(repr(bash_stderr), file=sys.stderr)
        ok = False

    if ok:
        print(f"[PASS] {scenario.name}")
    return ok


def main() -> int:
    if not MINISHELL.exists():
        print("minishell binary not found; run `make` first.", file=sys.stderr)
        return 1

    tmp_file = PROJECT_ROOT / "tests_realisation" / "e2e_tmp.txt"
    scenarios = [
        Scenario(
            name="echo_pipeline",
            script="echo foo bar | tr a-z A-Z\n",
        ),
        Scenario(
            name="variable_lifecycle",
            script="export MINI=codex\necho $MINI\nunset MINI\necho $MINI\n",
        ),
        Scenario(
            name="heredoc_basic",
            script="cat << EOF\nhello minishell\nEOF\n",
        ),
        Scenario(
            name="redirect_and_cleanup",
            script=f"echo 42 > {tmp_file}\ncat {tmp_file}\nrm -f {tmp_file}\n",
        ),
        Scenario(
            name="export_append",
            script="export MINI=foo\nexport MINI+=bar\necho $MINI\n",
        ),
        Scenario(
            name="tilde_variants",
            script="export HOME=/tmp/minishell_home\nexport OLDPWD=/tmp/minishell_old\necho ~\necho ~+\necho ~-\n",
        ),
    ]

    success = True
    for scenario in scenarios:
        if not compare_with_bash(scenario):
            success = False

    # Ensure temporary file is removed even if a test failed.
    try:
        tmp_file.unlink()
    except FileNotFoundError:
        pass

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
