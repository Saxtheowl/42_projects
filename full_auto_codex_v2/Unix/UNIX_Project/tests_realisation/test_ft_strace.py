import subprocess
import unittest
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
FT_STRACE = PROJECT_DIR / "ft_strace"


def run_command(*args: str) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        [str(FT_STRACE), *args],
        cwd=PROJECT_DIR,
        text=True,
        capture_output=True,
        check=False,
    )
    return result


class FtStraceTests(unittest.TestCase):
    def test_basic_execve(self) -> None:
        result = run_command("/bin/true")
        self.assertEqual(result.returncode, 0, msg=result.stderr)
        stdout = result.stdout.strip().splitlines()
        self.assertGreater(len(stdout), 1)
        self.assertTrue(stdout[0].startswith("execve("))
        self.assertTrue(stdout[-1].startswith("+++ exited with"))

    def test_echo_contains_write(self) -> None:
        result = run_command("/bin/echo", "hello")
        self.assertEqual(result.returncode, 0, msg=result.stderr)
        stdout = result.stdout
        self.assertIn("write(", stdout)
        self.assertIn("exit", stdout)


if __name__ == "__main__":
    unittest.main()
