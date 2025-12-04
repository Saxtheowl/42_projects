#!/usr/bin/env python3
import os
import signal
import socket
import subprocess
import sys
import time
from pathlib import Path


class TestError(RuntimeError):
	pass


class TestClient:
	def __init__(self, host, port, password, nick):
		self.sock = socket.create_connection((host, port))
		self.sock.settimeout(1.0)
		self.buffer = ""
		self.nick = nick
		self.send("PASS %s" % password)
		self.send("NICK %s" % nick)
		self.send("USER %s 0 * :%s" % (nick, nick))

	def close(self):
		try:
			self.send("QUIT :test end")
		except OSError:
			pass
		try:
			self.sock.close()
		except OSError:
			pass

	def send(self, line):
		payload = (line + "\r\n").encode("utf-8")
		self.sock.sendall(payload)

	def _drain(self, deadline):
		lines = []
		while True:
			while "\r\n" in self.buffer:
				line, self.buffer = self.buffer.split("\r\n", 1)
				lines.append(line)
			if time.time() >= deadline:
				break
			try:
				chunk = self.sock.recv(4096)
			except socket.timeout:
				break
			if not chunk:
				break
			self.buffer += chunk.decode("utf-8", errors="ignore")
		return lines

	def expect_contains(self, predicate, timeout=1.0):
		deadline = time.time() + timeout
		collected = []
		while time.time() < deadline:
			lines = self._drain(deadline)
			collected.extend(lines)
			for idx, line in enumerate(lines):
				if predicate(line):
					remaining = lines[idx + 1 :]
					if remaining:
						tail = "\r\n".join(remaining) + "\r\n"
						if self.buffer:
							tail += "\r\n" + self.buffer
						self.buffer = tail
					return line
		raise TestError("Did not observe expected response. Collected:\n%s" % "\n".join(collected))

	def expect_code(self, code, timeout=1.0):
		return self.expect_contains(lambda line: (" %s " % code) in line, timeout=timeout)


def find_free_port():
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.bind(("127.0.0.1", 0))
	addr, port = sock.getsockname()
	sock.close()
	return port


def main():
	root = Path(__file__).resolve().parents[1]
	binary = root / "ircserv"
	if not binary.exists():
		print("Error: build ./ircserv before running this script (run `make`).", file=sys.stderr)
		return 1

	port = find_free_port()
	password = "testpass"

	env = os.environ.copy()
	server = subprocess.Popen(
		[str(binary), str(port), password],
		cwd=str(root),
		stdout=subprocess.PIPE,
		stderr=subprocess.PIPE,
	)

	time.sleep(0.2)
	host = "127.0.0.1"

	alice = None
	bob = None
	try:
		alice = TestClient(host, port, password, "Alice")
		alice.expect_code("001", timeout=2.0)

		alice.send("JOIN #smoketest")
		alice.expect_contains(lambda line: " JOIN #smoketest" in line, timeout=2.0)
		alice.expect_code("353", timeout=2.0)

		bob = TestClient(host, port, password, "Bob")
		bob.expect_code("001", timeout=2.0)
		bob.send("JOIN #smoketest")
		bob.expect_contains(lambda line: " JOIN #smoketest" in line, timeout=2.0)

		# Bob should see Alice join earlier, Alice should see Bob join now
		alice.expect_contains(lambda line: "JOIN #smoketest" in line and "Bob" in line, timeout=2.0)

		alice.send("PRIVMSG #smoketest :hello from alice")
		bob.expect_contains(lambda line: "PRIVMSG #smoketest :hello from alice" in line, timeout=2.0)

		alice.send("MODE #smoketest +i")
		alice.expect_contains(lambda line: "MODE #smoketest +i" in line, timeout=2.0)

		alice.send("TOPIC #smoketest :demo topic")
		bob.expect_contains(lambda line: "TOPIC #smoketest :demo topic" in line, timeout=2.0)

		alice.send("KICK #smoketest Bob :cleanup")
		bob.expect_contains(lambda line: "KICK #smoketest Bob :cleanup" in line, timeout=2.0)
		alice.expect_contains(lambda line: "KICK #smoketest Bob :cleanup" in line, timeout=2.0)

		print("Smoke test passed.")
		return 0
	except TestError as exc:
		print("Smoke test failed:", exc, file=sys.stderr)
		return 2
	finally:
		for client in (alice, bob):
			if client is not None:
				client.close()
		if server.poll() is None:
			try:
				server.send_signal(signal.SIGTERM)
				server.wait(timeout=1.0)
			except Exception:
				server.kill()
		# Drain server output (avoid pipe deadlocks in longer sessions)
		for stream in (server.stdout, server.stderr):
			if stream:
				try:
					stream.close()
				except Exception:
					pass


if __name__ == "__main__":
	sys.exit(main())
