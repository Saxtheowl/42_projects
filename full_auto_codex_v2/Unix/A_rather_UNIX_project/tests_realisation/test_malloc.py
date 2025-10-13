import os
import subprocess
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
BUILD_DIR = PROJECT_ROOT
LIB_PATH = PROJECT_ROOT / "libft_malloc.so"
DRIVER_SRC = PROJECT_ROOT / "tests_realisation" / "test_driver.c"
DRIVER_BIN_DIR = PROJECT_ROOT / "tests_realisation" / "bin"
DRIVER_BIN = DRIVER_BIN_DIR / "test_driver"


def compile_driver() -> None:
    DRIVER_BIN_DIR.mkdir(parents=True, exist_ok=True)
    subprocess.run([
        "cc",
        "-Wall",
        "-Wextra",
        "-Werror",
        str(DRIVER_SRC),
        "-o",
        str(DRIVER_BIN),
        "-ldl",
    ], check=True, cwd=PROJECT_ROOT)


def run_driver(command: str) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["LD_PRELOAD"] = str(LIB_PATH.resolve())
    return subprocess.run(
        [str(DRIVER_BIN), command],
        cwd=PROJECT_ROOT,
        text=True,
        capture_output=True,
        env=env,
        check=False,
    )


class MallocTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        compile_driver()

    def test_basic_allocation(self) -> None:
        result = run_driver("basic")
        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(result.stdout.strip(), "hello world")

    def test_realloc_preserves_data(self) -> None:
        result = run_driver("realloc")
        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(result.stdout.strip(), "65 65 65 0")

    def test_large_allocation(self) -> None:
        result = run_driver("large")
        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(result.stdout.strip(), "LX")

    def test_show_alloc_mem_output(self) -> None:
        result = run_driver("show")
        self.assertEqual(result.returncode, 0, msg=result.stderr)
        stdout = result.stdout
        self.assertIn("TINY", stdout)
        self.assertIn("SMALL", stdout)
        self.assertIn("LARGE", stdout)
        self.assertIn("Total", stdout)


if __name__ == "__main__":
    unittest.main()
