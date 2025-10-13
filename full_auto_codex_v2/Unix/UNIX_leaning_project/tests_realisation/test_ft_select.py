import os
import pty
import re
import select
import subprocess
import time
import unittest
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
BINARY = PROJECT_DIR / "ft_select"

ANSI_ESCAPE = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")


def run_interactive(args, keys, timeout=2.0):
    master, slave = pty.openpty()
    env = os.environ.copy()
    proc = subprocess.Popen(
        [str(BINARY), *args],
        stdin=slave,
        stdout=slave,
        stderr=slave,
        cwd=PROJECT_DIR,
        env=env,
    )
    os.close(slave)
    time.sleep(0.1)
    os.write(master, keys)
    output_chunks: list[bytes] = []
    end = time.time() + timeout
    while time.time() < end:
        if proc.poll() is not None and not select.select([master], [], [], 0)[0]:
            break
        rlist, _, _ = select.select([master], [], [], 0.05)
        if master in rlist:
            try:
                data = os.read(master, 4096)
            except OSError:
                break
            if not data:
                break
            output_chunks.append(data)
    if proc.poll() is None:
        proc.terminate()
    try:
        while True:
            data = os.read(master, 4096)
            if not data:
                break
            output_chunks.append(data)
    except OSError:
        pass
    os.close(master)
    returncode = proc.wait()
    return returncode, b"".join(output_chunks).decode(errors="ignore")


def clean_output(text: str) -> str:
    text = ANSI_ESCAPE.sub("", text)
    text = text.replace("\r", "")
    return text.strip()


class FtSelectTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        subprocess.run(["make"], cwd=PROJECT_DIR, check=True)

    def test_select_single_item(self) -> None:
        code, out = run_interactive(["alpha", "beta"], b" \n")
        self.assertEqual(code, 0)
        cleaned = clean_output(out)
        self.assertIn("alpha", cleaned)

    def test_escape_exit(self) -> None:
        code, out = run_interactive(["foo", "bar"], b"\x1b")
        self.assertNotEqual(code, 0)
        cleaned = clean_output(out)
        self.assertNotIn("foo", cleaned)
        self.assertNotIn("bar", cleaned)


if __name__ == "__main__":
    unittest.main()
