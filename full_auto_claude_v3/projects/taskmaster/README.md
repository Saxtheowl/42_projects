# taskmaster - Process Manager

Supervisor-like process control daemon for managing and monitoring processes.

## Features

- Process lifecycle management (start, stop, restart)
- Automatic restart on failure
- Process monitoring
- Log file management
- Configuration file support
- Interactive control shell
- Multiple process instances

## Usage

```bash
python3 taskmaster.py              # Run demo
python3 taskmaster.py -c config.json  # Load config
python3 taskmaster.py -i           # Interactive shell
```

## Configuration

Create a JSON config file:

```json
{
  "programs": [
    {
      "name": "myapp",
      "command": "/path/to/myapp",
      "directory": "/path/to/workdir",
      "autostart": true,
      "autorestart": "unexpected",
      "startsecs": 1,
      "startretries": 3,
      "stopwaitsecs": 10,
      "stopsignal": "TERM",
      "stdout_logfile": "/var/log/myapp.log",
      "stderr_logfile": "/var/log/myapp.err",
      "environment": {
        "ENV_VAR": "value"
      },
      "numprocs": 1,
      "exitcodes": [0]
    }
  ]
}
```

## Process States

| State | Description |
|-------|-------------|
| STOPPED | Not running |
| STARTING | Starting up (before startsecs) |
| RUNNING | Running normally |
| STOPPING | Being stopped |
| EXITED | Exited (not restarting) |
| FATAL | Failed after max retries |
| BACKOFF | Waiting to retry |

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `name` | required | Process name |
| `command` | required | Command to run |
| `directory` | "" | Working directory |
| `autostart` | true | Start on daemon startup |
| `autorestart` | "unexpected" | "true", "false", or "unexpected" |
| `startsecs` | 1 | Seconds before considered started |
| `startretries` | 3 | Max restart attempts |
| `stopwaitsecs` | 10 | Wait time before SIGKILL |
| `stopsignal` | "TERM" | Signal to stop process |
| `numprocs` | 1 | Number of instances |
| `exitcodes` | [0] | Expected exit codes |

## Shell Commands

| Command | Description |
|---------|-------------|
| `status` | Show all process status |
| `start <name>` | Start a process |
| `stop <name>` | Stop a process |
| `restart <name>` | Restart a process |
| `start all` | Start all processes |
| `stop all` | Stop all processes |
| `reload` | Reload configuration |
| `tail <name>` | Show recent logs |
| `exit` | Exit shell |

## Signals

Supported stop signals:
- TERM, HUP, INT, QUIT, USR1, USR2, KILL

## Author

Implementation for 42 curriculum.
