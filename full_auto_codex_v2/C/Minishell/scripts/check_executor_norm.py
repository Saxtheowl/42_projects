#!/usr/bin/env python3
"""
Quick sanity-check for executor files against 42-style constraints.

It counts functions in each src/executor/*.c file and reports their
individual line counts so we can spot anything that would violate the
<= 5 functions / <= 25 lines per function rules before running norminette.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator

ROOT = Path(__file__).resolve().parents[1]
EXECUTOR_DIR = ROOT / "src" / "executor"


FUNC_HEADER_RE = re.compile(r"^[a-zA-Z_][\w\s\*]*\([\w\s\*,\[\]\(\)]*\)\s*$")


@dataclass
class FunctionInfo:
    name: str
    start_line: int
    end_line: int

    @property
    def line_count(self) -> int:
        return self.end_line - self.start_line + 1


def iter_functions(path: Path) -> Iterator[FunctionInfo]:
    with path.open("r", encoding="utf-8") as fh:
        lines = fh.readlines()

    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip().startswith("static ") or line.strip().startswith(path.stem):
            header_lines = [line.rstrip("\n")]
            j = i + 1
            while j < len(lines) and "{" not in lines[j]:
                header_lines.append(lines[j].rstrip("\n"))
                j += 1
            if j >= len(lines):
                break
            header = " ".join(h.strip() for h in header_lines)
            if header.endswith(")") and not header.endswith(");"):
                depth = 0
                start = i + 1
                k = j
                if "{" in lines[k]:
                    depth += lines[k].count("{") - lines[k].count("}")
                k += 1
                while k < len(lines) and depth > 0:
                    depth += lines[k].count("{") - lines[k].count("}")
                    k += 1
                name_match = re.search(r"([a-zA-Z_][\w]*)\s*\(", header)
                name = name_match.group(1) if name_match else "<anonymous>"
                yield FunctionInfo(name=name, start_line=start, end_line=k)
                i = k
                continue
        i += 1


def main() -> None:
    for file_path in sorted(EXECUTOR_DIR.glob("*.c")):
        funcs = list(iter_functions(file_path))
        print(f"{file_path.relative_to(ROOT)}: {len(funcs)} functions")
        for fn in funcs:
            flag = ""
            if fn.line_count > 25:
                flag = "  <-- exceeds 25 lines"
            print(f"  {fn.name:<24} {fn.line_count:>2}{flag}")
        if len(funcs) > 5:
            print("  !! more than 5 functions in file")
        print()


if __name__ == "__main__":
    main()
