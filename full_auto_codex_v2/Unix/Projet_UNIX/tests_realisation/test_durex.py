import os
import socket
import subprocess
import tempfile
import time
import unittest
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
BINARY = PROJECT_DIR / "Durex"


class DurexTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.prefix = Path(self.tempdir.name)
        self.env = os.environ.copy()
        self.env.update({
            "DUREX_ALLOW_UNSAFE": "1",
            "DUREX_PREFIX": str(self.prefix),
            "DUREX_PORT": "4424",
            "DUREX_PASSWORD": "unittest-password",
        })

    def tearDown(self) -> None:
        pid_file = self.prefix / "var" / "run" / "Durex.pid"
        if pid_file.exists():
            try:
                pid = int(pid_file.read_text().strip())
                os.kill(pid, 15)
            except Exception:
                pass
        self.tempdir.cleanup()

    def wait_for_port(self, port: int, timeout: float = 3.0) -> None:
        end = time.time() + timeout
        while time.time() < end:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(0.2)
                if s.connect_ex(("127.0.0.1", port)) == 0:
                    return
            time.sleep(0.05)
        self.fail("Server port did not open in time")

    def read_until(self, sock: socket.socket, token: str, timeout: float = 2.0) -> str:
        sock.settimeout(timeout)
        chunks: list[str] = []
        while token not in ''.join(chunks):
            data = sock.recv(4096)
            if not data:
                break
            chunks.append(data.decode())
        return ''.join(chunks)

    def test_install_and_daemon(self) -> None:
        proc = subprocess.run([str(BINARY)], capture_output=True, text=True, env=self.env, cwd=PROJECT_DIR)
        self.assertEqual(proc.returncode, 0, msg=proc.stderr)
        self.assertIn(proc.stdout.strip(), {os.getenv("USER", "unknown"), "unknown"})

        bin_path = self.prefix / "bin" / "Durex"
        service_path = self.prefix / "etc" / "init.d" / "Durex"
        self.assertTrue(bin_path.exists())
        self.assertTrue(service_path.exists())

        self.wait_for_port(4424)

        with socket.create_connection(("127.0.0.1", 4424), timeout=2.0) as sock:
            data = self.read_until(sock, "Keycode:")
            self.assertIn("Keycode", data)
            sock.sendall(b"unittest-password\n")
            prompt = self.read_until(sock, "$> ")
            self.assertIn("$> ", prompt)
            sock.sendall(b"help\n")
            help_output = self.read_until(sock, "$> ")
            self.assertIn("shell", help_output)
            sock.sendall(b"shell\n")
            time.sleep(0.1)
            sock.sendall(b"id\n")
            shell_output = self.read_until(sock, "id")
            self.assertIn("id", shell_output)


if __name__ == "__main__":
    unittest.main()
