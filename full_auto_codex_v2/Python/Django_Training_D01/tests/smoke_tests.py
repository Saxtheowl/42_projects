#!/usr/bin/env python3
import subprocess
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parents[1]


def run_script(relative_path, args=None):
    script_path = BASE_DIR / relative_path
    cmd = ["python3", str(script_path)]
    if args:
        cmd.extend(args)
    result = subprocess.run(cmd, capture_output=True, text=True, check=False)
    return result.stdout.strip(), result.stderr.strip(), result.returncode


def assert_equal(actual, expected, message):
    if actual != expected:
        raise AssertionError(f"{message}: expected {expected!r}, got {actual!r}")


def assert_true(condition, message):
    if not condition:
        raise AssertionError(message)


def test_ex00():
    stdout, _, code = run_script("ex00/var.py")
    assert_equal(code, 0, "ex00 exit code")
    lines = [line for line in stdout.splitlines() if line.strip()]
    assert_equal(len(lines), 9, "ex00 line count")
    assert_true(all("has a type" in line for line in lines), "ex00 output format")


def test_ex01():
    stdout, _, code = run_script("ex01/numbers.py")
    assert_equal(code, 0, "ex01 exit code")
    numbers = [line.strip() for line in stdout.splitlines() if line.strip()]
    assert_equal(len(numbers), 100, "ex01 line count")
    assert_equal(numbers[0], "1", "ex01 first number")
    assert_equal(numbers[-1], "100", "ex01 last number")


def test_ex02():
    stdout, _, code = run_script("ex02/var_to_dict.py")
    assert_equal(code, 0, "ex02 exit code")
    lines = [line for line in stdout.splitlines() if line.strip()]
    data = [
        ("Hendrix", "1942"),
        ("Allman", "1946"),
        ("King", "1925"),
        ("Clapton", "1945"),
        ("Johnson", "1911"),
        ("Berry", "1926"),
        ("Vaughan", "1954"),
        ("Cooder", "1947"),
        ("Page", "1944"),
        ("Richards", "1943"),
        ("Hammett", "1962"),
        ("Cobain", "1967"),
        ("Garcia", "1942"),
        ("Beck", "1944"),
        ("Santana", "1947"),
        ("Ramone", "1948"),
        ("White", "1975"),
        ("Frusciante", "1970"),
        ("Thompson", "1949"),
        ("Burton", "1939"),
    ]
    expected_count = len({year for _, year in data})
    assert_equal(len(lines), expected_count, "ex02 unique year count")
    assert_true(all(" : " in line for line in lines), "ex02 format")
    assert_true("1942 : Garcia" in lines, "ex02 1942 entry")


def test_ex03():
    stdout, _, code = run_script("ex03/capital_city.py", ["Oregon"])
    assert_equal(code, 0, "ex03 exit code")
    assert_equal(stdout, "Salem", "ex03 Oregon")
    stdout, _, code = run_script("ex03/capital_city.py", ["Nowhere"])
    assert_equal(code, 0, "ex03 exit code (unknown)")
    assert_equal(stdout, "Unknown state", "ex03 unknown state")


def test_ex04():
    stdout, _, code = run_script("ex04/state.py", ["Denver"])
    assert_equal(code, 0, "ex04 exit code")
    assert_equal(stdout, "Colorado", "ex04 Denver")
    stdout, _, code = run_script("ex04/state.py", ["Atlantis"])
    assert_equal(code, 0, "ex04 exit code (unknown)")
    assert_equal(stdout, "Unknown capital city", "ex04 unknown capital")


def test_ex05():
    stdout, _, code = run_script("ex05/all_in.py", ["New jersey, Trenton, Salem"])
    assert_equal(code, 0, "ex05 exit code")
    lines = [line for line in stdout.splitlines() if line.strip()]
    assert_equal(len(lines), 3, "ex05 line count")
    assert_true("Trenton is the capital of New Jersey" in lines, "ex05 Trenton")
    assert_true("Salem is the capital of Oregon" in lines, "ex05 Salem")
    stdout, _, code = run_script("ex05/all_in.py", ["Neverland"])
    assert_equal(code, 0, "ex05 exit code (unknown)")
    assert_equal(stdout, "Neverland is neither a capital city nor a state",
                 "ex05 unknown")


def test_ex06():
    stdout, _, code = run_script("ex06/my_sort.py")
    assert_equal(code, 0, "ex06 exit code")
    lines = [line for line in stdout.splitlines() if line.strip()]
    assert_equal(len(lines), 20, "ex06 line count")
    assert_equal(lines[0], "Johnson", "ex06 first entry")
    assert_equal(lines[-1], "White", "ex06 last entry")


def test_ex07():
    stdout, _, code = run_script("ex07/periodic_table.py")
    assert_equal(code, 0, "ex07 exit code")
    assert_equal(stdout, "", "ex07 stdout")
    output_path = BASE_DIR / "ex07" / "periodic_table.html"
    assert_true(output_path.exists(), "ex07 output exists")
    content = output_path.read_text(encoding="utf-8")
    assert_true("<table>" in content, "ex07 html table")
    assert_true("Hydrogen" in content, "ex07 includes Hydrogen")


def main():
    tests = [
        test_ex00,
        test_ex01,
        test_ex02,
        test_ex03,
        test_ex04,
        test_ex05,
        test_ex06,
        test_ex07,
    ]
    for test in tests:
        test()
    print(f"OK: {len(tests)} tests passed")


if __name__ == "__main__":
    main()
