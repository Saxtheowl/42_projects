#!/usr/bin/env python3
"""
taskmaster - Process Manager
Supervisor-like process control daemon
"""

import sys
import os
import signal
import subprocess
import threading
import time
import json
import socket
from dataclasses import dataclass, field, asdict
from typing import Dict, List, Optional, Callable
from enum import Enum
from datetime import datetime
import select


class ProcessState(Enum):
    STOPPED = "STOPPED"
    STARTING = "STARTING"
    RUNNING = "RUNNING"
    STOPPING = "STOPPING"
    EXITED = "EXITED"
    FATAL = "FATAL"
    BACKOFF = "BACKOFF"


@dataclass
class ProcessConfig:
    """Configuration for a managed process."""
    name: str
    command: str
    directory: str = ""
    autostart: bool = True
    autorestart: str = "unexpected"  # "true", "false", "unexpected"
    startsecs: int = 1
    startretries: int = 3
    stopwaitsecs: int = 10
    stopsignal: str = "TERM"
    stdout_logfile: str = ""
    stderr_logfile: str = ""
    environment: Dict[str, str] = field(default_factory=dict)
    numprocs: int = 1
    exitcodes: List[int] = field(default_factory=lambda: [0])
    user: str = ""
    umask: str = ""


@dataclass
class ProcessInfo:
    """Runtime information about a process."""
    config: ProcessConfig
    state: ProcessState = ProcessState.STOPPED
    pid: Optional[int] = None
    start_time: Optional[datetime] = None
    stop_time: Optional[datetime] = None
    exit_code: Optional[int] = None
    retries: int = 0
    process: Optional[subprocess.Popen] = None

    def uptime(self) -> str:
        """Get uptime string."""
        if self.start_time is None:
            return "0:00:00"
        delta = datetime.now() - self.start_time
        hours, remainder = divmod(int(delta.total_seconds()), 3600)
        minutes, seconds = divmod(remainder, 60)
        return f"{hours}:{minutes:02d}:{seconds:02d}"


class TaskMaster:
    """Process manager daemon."""

    SIGNALS = {
        "TERM": signal.SIGTERM,
        "HUP": signal.SIGHUP,
        "INT": signal.SIGINT,
        "QUIT": signal.SIGQUIT,
        "USR1": signal.SIGUSR1,
        "USR2": signal.SIGUSR2,
        "KILL": signal.SIGKILL,
    }

    def __init__(self, config_file: str = ""):
        self.processes: Dict[str, ProcessInfo] = {}
        self.running = False
        self.config_file = config_file
        self.log_lines: List[str] = []
        self.lock = threading.Lock()

    def log(self, message: str):
        """Log a message."""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        line = f"[{timestamp}] {message}"
        with self.lock:
            self.log_lines.append(line)
            if len(self.log_lines) > 1000:
                self.log_lines = self.log_lines[-500:]
        print(line)

    def add_program(self, config: ProcessConfig):
        """Add a program configuration."""
        for i in range(config.numprocs):
            name = config.name if config.numprocs == 1 else f"{config.name}_{i}"
            program_config = ProcessConfig(
                name=name,
                command=config.command,
                directory=config.directory,
                autostart=config.autostart,
                autorestart=config.autorestart,
                startsecs=config.startsecs,
                startretries=config.startretries,
                stopwaitsecs=config.stopwaitsecs,
                stopsignal=config.stopsignal,
                stdout_logfile=config.stdout_logfile.replace("%(program_name)s", name),
                stderr_logfile=config.stderr_logfile.replace("%(program_name)s", name),
                environment=config.environment,
                numprocs=1,
                exitcodes=config.exitcodes,
                user=config.user,
                umask=config.umask,
            )
            self.processes[name] = ProcessInfo(config=program_config)
            self.log(f"Added program: {name}")

    def start_program(self, name: str) -> bool:
        """Start a program."""
        if name not in self.processes:
            self.log(f"Program not found: {name}")
            return False

        info = self.processes[name]

        if info.state in [ProcessState.RUNNING, ProcessState.STARTING]:
            self.log(f"{name}: already running")
            return False

        self.log(f"Starting: {name}")
        info.state = ProcessState.STARTING
        info.retries = 0

        return self._spawn_process(name)

    def _spawn_process(self, name: str) -> bool:
        """Spawn a process."""
        info = self.processes[name]
        config = info.config

        try:
            # Prepare environment
            env = os.environ.copy()
            env.update(config.environment)

            # Prepare command
            cmd = config.command.split()

            # Open log files
            stdout_file = None
            stderr_file = None

            if config.stdout_logfile:
                stdout_file = open(config.stdout_logfile, 'a')
            if config.stderr_logfile:
                stderr_file = open(config.stderr_logfile, 'a')

            # Start process
            cwd = config.directory if config.directory else None

            process = subprocess.Popen(
                cmd,
                stdout=stdout_file or subprocess.DEVNULL,
                stderr=stderr_file or subprocess.DEVNULL,
                cwd=cwd,
                env=env,
                start_new_session=True,
            )

            info.process = process
            info.pid = process.pid
            info.start_time = datetime.now()
            info.exit_code = None
            info.stop_time = None

            # Wait for startsecs
            threading.Thread(
                target=self._check_start,
                args=(name, config.startsecs),
                daemon=True
            ).start()

            self.log(f"Spawned: {name} (PID {info.pid})")
            return True

        except Exception as e:
            self.log(f"Failed to start {name}: {e}")
            info.state = ProcessState.FATAL
            return False

    def _check_start(self, name: str, startsecs: int):
        """Check if process started successfully."""
        time.sleep(startsecs)

        if name not in self.processes:
            return

        info = self.processes[name]

        if info.process and info.process.poll() is None:
            info.state = ProcessState.RUNNING
            self.log(f"{name}: entered RUNNING state")
        elif info.state == ProcessState.STARTING:
            self._handle_exit(name)

    def _handle_exit(self, name: str):
        """Handle process exit."""
        if name not in self.processes:
            return

        info = self.processes[name]
        config = info.config

        if info.process:
            info.exit_code = info.process.poll()

        info.stop_time = datetime.now()
        info.pid = None

        expected = info.exit_code in config.exitcodes

        self.log(f"{name}: exited with code {info.exit_code} ({'expected' if expected else 'unexpected'})")

        # Decide whether to restart
        should_restart = False

        if config.autorestart == "true":
            should_restart = True
        elif config.autorestart == "unexpected" and not expected:
            should_restart = True

        if should_restart and info.retries < config.startretries:
            info.retries += 1
            info.state = ProcessState.BACKOFF
            self.log(f"{name}: retry {info.retries}/{config.startretries}")

            # Exponential backoff
            delay = min(2 ** info.retries, 60)
            threading.Timer(delay, lambda: self._spawn_process(name)).start()
        else:
            if info.retries >= config.startretries:
                info.state = ProcessState.FATAL
                self.log(f"{name}: max retries reached, entering FATAL state")
            else:
                info.state = ProcessState.EXITED

    def stop_program(self, name: str) -> bool:
        """Stop a program."""
        if name not in self.processes:
            self.log(f"Program not found: {name}")
            return False

        info = self.processes[name]

        if info.state not in [ProcessState.RUNNING, ProcessState.STARTING]:
            self.log(f"{name}: not running")
            return False

        self.log(f"Stopping: {name}")
        info.state = ProcessState.STOPPING

        if info.process:
            sig = self.SIGNALS.get(info.config.stopsignal, signal.SIGTERM)
            try:
                os.killpg(os.getpgid(info.process.pid), sig)
            except ProcessLookupError:
                pass

            # Wait for process to stop
            threading.Thread(
                target=self._wait_stop,
                args=(name,),
                daemon=True
            ).start()

        return True

    def _wait_stop(self, name: str):
        """Wait for process to stop."""
        if name not in self.processes:
            return

        info = self.processes[name]

        if not info.process:
            info.state = ProcessState.STOPPED
            return

        # Wait for stopwaitsecs
        for _ in range(info.config.stopwaitsecs * 10):
            if info.process.poll() is not None:
                break
            time.sleep(0.1)

        # Force kill if still running
        if info.process.poll() is None:
            self.log(f"{name}: sending SIGKILL")
            try:
                os.killpg(os.getpgid(info.process.pid), signal.SIGKILL)
            except ProcessLookupError:
                pass

        info.exit_code = info.process.poll()
        info.stop_time = datetime.now()
        info.pid = None
        info.state = ProcessState.STOPPED
        self.log(f"{name}: stopped")

    def restart_program(self, name: str) -> bool:
        """Restart a program."""
        if name not in self.processes:
            self.log(f"Program not found: {name}")
            return False

        self.stop_program(name)

        # Wait for stop
        for _ in range(100):
            if self.processes[name].state == ProcessState.STOPPED:
                break
            time.sleep(0.1)

        return self.start_program(name)

    def status(self) -> str:
        """Get status of all programs."""
        lines = []
        for name, info in sorted(self.processes.items()):
            state = info.state.value
            pid = info.pid or "-"
            uptime = info.uptime() if info.state == ProcessState.RUNNING else "-"
            lines.append(f"{name:20s} {state:10s} pid {str(pid):8s} uptime {uptime}")

        return "\n".join(lines) if lines else "No programs configured"

    def status_json(self) -> str:
        """Get status as JSON."""
        data = {}
        for name, info in self.processes.items():
            data[name] = {
                "state": info.state.value,
                "pid": info.pid,
                "uptime": info.uptime() if info.state == ProcessState.RUNNING else None,
                "exit_code": info.exit_code,
                "retries": info.retries,
            }
        return json.dumps(data, indent=2)

    def start_all(self):
        """Start all programs with autostart."""
        for name, info in self.processes.items():
            if info.config.autostart:
                self.start_program(name)

    def stop_all(self):
        """Stop all running programs."""
        for name, info in self.processes.items():
            if info.state in [ProcessState.RUNNING, ProcessState.STARTING]:
                self.stop_program(name)

    def monitor(self):
        """Monitor processes and handle restarts."""
        while self.running:
            for name, info in list(self.processes.items()):
                if info.process and info.state == ProcessState.RUNNING:
                    if info.process.poll() is not None:
                        self._handle_exit(name)

            time.sleep(1)

    def load_config(self, config_file: str):
        """Load configuration from file."""
        with open(config_file, 'r') as f:
            config = json.load(f)

        for prog_config in config.get("programs", []):
            self.add_program(ProcessConfig(
                name=prog_config["name"],
                command=prog_config["command"],
                directory=prog_config.get("directory", ""),
                autostart=prog_config.get("autostart", True),
                autorestart=prog_config.get("autorestart", "unexpected"),
                startsecs=prog_config.get("startsecs", 1),
                startretries=prog_config.get("startretries", 3),
                stopwaitsecs=prog_config.get("stopwaitsecs", 10),
                stopsignal=prog_config.get("stopsignal", "TERM"),
                stdout_logfile=prog_config.get("stdout_logfile", ""),
                stderr_logfile=prog_config.get("stderr_logfile", ""),
                environment=prog_config.get("environment", {}),
                numprocs=prog_config.get("numprocs", 1),
                exitcodes=prog_config.get("exitcodes", [0]),
            ))

    def run_daemon(self):
        """Run as daemon."""
        self.running = True
        self.log("TaskMaster starting...")

        # Start monitor thread
        monitor_thread = threading.Thread(target=self.monitor, daemon=True)
        monitor_thread.start()

        # Start autostart programs
        self.start_all()

        self.log("TaskMaster started")

        # Wait for shutdown
        try:
            while self.running:
                time.sleep(1)
        except KeyboardInterrupt:
            self.shutdown()

    def shutdown(self):
        """Shutdown daemon."""
        self.log("TaskMaster shutting down...")
        self.running = False
        self.stop_all()

        # Wait for all processes to stop
        for _ in range(100):
            all_stopped = all(
                info.state in [ProcessState.STOPPED, ProcessState.EXITED, ProcessState.FATAL]
                for info in self.processes.values()
            )
            if all_stopped:
                break
            time.sleep(0.1)

        self.log("TaskMaster stopped")


def interactive_shell(tm: TaskMaster):
    """Run interactive control shell."""
    print("TaskMaster Control Shell")
    print("Type 'help' for commands")
    print()

    while True:
        try:
            cmd = input("taskmaster> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break

        if not cmd:
            continue

        parts = cmd.split()
        command = parts[0].lower()
        args = parts[1:]

        if command == "help":
            print("Commands:")
            print("  status              - Show status of all programs")
            print("  start <name>        - Start a program")
            print("  stop <name>         - Stop a program")
            print("  restart <name>      - Restart a program")
            print("  start all           - Start all programs")
            print("  stop all            - Stop all programs")
            print("  reload              - Reload configuration")
            print("  tail <name>         - Tail program logs")
            print("  exit                - Exit shell")

        elif command == "status":
            print(tm.status())

        elif command == "start":
            if not args:
                print("Usage: start <name|all>")
            elif args[0] == "all":
                tm.start_all()
            else:
                tm.start_program(args[0])

        elif command == "stop":
            if not args:
                print("Usage: stop <name|all>")
            elif args[0] == "all":
                tm.stop_all()
            else:
                tm.stop_program(args[0])

        elif command == "restart":
            if not args:
                print("Usage: restart <name>")
            else:
                tm.restart_program(args[0])

        elif command == "reload":
            if tm.config_file:
                print(f"Reloading: {tm.config_file}")
                tm.load_config(tm.config_file)
            else:
                print("No config file specified")

        elif command == "tail":
            if not args:
                print("Usage: tail <name>")
            elif args[0] in tm.processes:
                info = tm.processes[args[0]]
                if info.config.stdout_logfile and os.path.exists(info.config.stdout_logfile):
                    with open(info.config.stdout_logfile, 'r') as f:
                        lines = f.readlines()[-20:]
                        print("".join(lines))
                else:
                    print("No log file configured or file not found")
            else:
                print(f"Unknown program: {args[0]}")

        elif command in ["exit", "quit"]:
            break

        else:
            print(f"Unknown command: {command}")


def run_demo():
    """Run demonstration."""
    print("TaskMaster Demo")
    print("=" * 50)

    tm = TaskMaster()

    # Add demo programs
    tm.add_program(ProcessConfig(
        name="sleeper",
        command="sleep 30",
        autostart=True,
        autorestart="true",
    ))

    tm.add_program(ProcessConfig(
        name="echo_loop",
        command="bash -c 'while true; do echo hello; sleep 5; done'",
        autostart=True,
        autorestart="unexpected",
    ))

    tm.add_program(ProcessConfig(
        name="failing",
        command="false",
        autostart=False,
        autorestart="true",
        startretries=2,
    ))

    print("\nPrograms configured:")
    print(tm.status())

    print("\nStarting all programs...")
    tm.start_all()

    time.sleep(3)
    print("\nStatus after 3 seconds:")
    print(tm.status())

    print("\nStopping sleeper...")
    tm.stop_program("sleeper")

    time.sleep(2)
    print("\nFinal status:")
    print(tm.status())

    print("\nStopping all...")
    tm.stop_all()
    time.sleep(2)

    print("\n" + "=" * 50)
    print("Demo complete!")


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--help':
            print("taskmaster - Process Manager")
            print("\nUsage:")
            print("  python taskmaster.py              - Run demo")
            print("  python taskmaster.py -c config    - Load config and run")
            print("  python taskmaster.py -i           - Interactive mode")
            return

        elif sys.argv[1] == '-c' and len(sys.argv) > 2:
            tm = TaskMaster(config_file=sys.argv[2])
            tm.load_config(sys.argv[2])
            tm.run_daemon()
            return

        elif sys.argv[1] == '-i':
            tm = TaskMaster()
            interactive_shell(tm)
            return

    run_demo()


if __name__ == "__main__":
    main()
