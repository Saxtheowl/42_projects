#!/usr/bin/env python3
from pathlib import Path
import sys


PROJECT_ROOT = Path(__file__).resolve().parent.parent


def slurp(relative_path: str) -> str:
    return (PROJECT_ROOT / relative_path).read_text(encoding="utf-8")


def ensure(condition: bool, message: str, issues: list[str]) -> None:
    if not condition:
        issues.append(message)


def main() -> int:
    issues: list[str] = []

    ex00 = slurp("ex00/index.html")
    ensure("Hello 42!" in ex00, "ex00: expected “Hello 42!” in the rendered output.", issues)
    ensure("<title>My first Vue app for 42</title>" in ex00, "ex00: missing required <title>.", issues)

    ex01 = slurp("ex01/index.html")
    ensure("v-if" in ex01, "ex01: the message should be conditionally rendered with v-if.", issues)
    ensure("seen:true" in "".join(ex01.split()), "ex01: data object must define seen: true.", issues)

    ex02 = slurp("ex02/index.html")
    ensure("SHOW" in ex02 and "HIDE" in ex02, "ex02: expected SHOW/HIDE buttons.", issues)
    ensure("@click=\"setVisibility(true)\"" in ex02, "ex02: SHOW button must set seen to true.", issues)
    ensure("@click=\"setVisibility(false)\"" in ex02, "ex02: HIDE button must set seen to false.", issues)

    ex03 = slurp("ex03/index.html")
    ensure("v-model=\"message\"" in ex03, "ex03: input must be bound with v-model.", issues)

    ex04 = slurp("ex04/index.html")
    ensure("Vue.component('hello'" in ex04, "ex04: hello component must be declared.", issues)
    ensure("<hello>" in ex04, "ex04: hello component must be used in the template.", issues)

    ex05 = slurp("ex05/index.html")
    ensure("Vue.component('series-item'" in ex05, "ex05: series-item component must be declared.", issues)
    ensure("NetflixList" in ex05, "ex05: NetflixList data property must be present.", issues)
    ensure("v-for=\"series in NetflixList\"" in ex05, "ex05: component usage must iterate over NetflixList.", issues)

    if issues:
        print("Tests failed:", file=sys.stderr)
        for issue in issues:
            print(f"- {issue}", file=sys.stderr)
        return 1

    print("All hello_vue checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
