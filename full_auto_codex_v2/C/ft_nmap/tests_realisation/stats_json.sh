#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_json="$(mktemp)"
trap 'rm -f "$out_json"' EXIT

echo "Checking stats fields in JSON export..."
./ft_nmap -t 127.0.0.1 -p 22,80,443 -T 200 -q -o "$out_json" -Y "$out_json.yaml"

python3 - "$out_json" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)
if data.get("scan_type") != "tcp":
    print(f"Expected scan_type=tcp by default, got {data.get('scan_type')}", file=sys.stderr)
    sys.exit(1)
stats = data.get("stats", {})
required = ["requested", "scanned", "excluded", "open", "closed", "timeouts",
            "retries", "elapsed_ms", "start_ms", "end_ms",
            "duration_min_ms", "duration_max_ms", "duration_mean_ms",
            "pending", "deadline_ms", "deadline_hit", "delay_ms",
            "randomized", "random_seed", "retry_backoff_pct",
            "open_rate", "closed_rate", "timeout_rate",
            "avg_retries_per_port", "first_open_ms",
            "fastest_port", "fastest_duration_ms",
            "slowest_port", "slowest_duration_ms",
            "timeout_stop_hit", "timeout_stop_threshold"]
missing = [k for k in required if k not in stats]
if missing:
    print(f"Missing stats keys: {missing}", file=sys.stderr)
    sys.exit(1)
if stats["randomized"] is not False:
    print(f"Expected randomized=false by default, got {stats['randomized']}", file=sys.stderr)
    sys.exit(1)
if stats["random_seed"] != 0:
    print(f"Expected random_seed=0 when not randomized, got {stats['random_seed']}", file=sys.stderr)
    sys.exit(1)
if stats.get("timeout_stop_hit") not in (False, 0):
    print(f"Expected timeout_stop_hit=false by default, got {stats.get('timeout_stop_hit')}", file=sys.stderr)
    sys.exit(1)
if int(stats.get("timeout_stop_threshold", -1)) != 0:
    print(f"Expected timeout_stop_threshold=0 by default, got {stats.get('timeout_stop_threshold')}", file=sys.stderr)
    sys.exit(1)
if stats["requested"] != 3 or stats["scanned"] != 3:
    print(f"Unexpected requested/scanned values: {stats['requested']} / {stats['scanned']}", file=sys.stderr)
    sys.exit(1)
if stats["pending"] != 0 or stats["deadline_hit"]:
    print(f"Unexpected pending/deadline flags: pending={stats['pending']} hit={stats['deadline_hit']}", file=sys.stderr)
    sys.exit(1)
if stats["delay_ms"] != 0:
    print(f"Expected delay_ms=0, got {stats['delay_ms']}", file=sys.stderr)
    sys.exit(1)
if int(stats.get("retry_backoff_pct", -1)) != 0:
    print(f"Expected retry_backoff_pct=0 by default, got {stats.get('retry_backoff_pct')}", file=sys.stderr)
    sys.exit(1)
for key in ("open_rate", "closed_rate", "timeout_rate"):
    if not (0 <= float(stats[key]) <= 100):
        print(f"Rate {key} out of bounds: {stats[key]}", file=sys.stderr)
        sys.exit(1)
total = float(stats["open_rate"]) + float(stats["closed_rate"]) + float(stats["timeout_rate"])
if total > 100.01:
    print(f"Rates sum unexpectedly high: {total}", file=sys.stderr)
    sys.exit(1)
if float(stats["avg_retries_per_port"]) < 0:
    print(f"avg_retries_per_port negative: {stats['avg_retries_per_port']}", file=sys.stderr)
    sys.exit(1)
if stats.get("first_open_ms", 0) != -1:
    print(f"Expected first_open_ms=-1 when no open ports, got {stats.get('first_open_ms')}", file=sys.stderr)
    sys.exit(1)
for key in ("fastest_duration_ms", "slowest_duration_ms"):
    if float(stats[key]) < 0:
        print(f"{key} negative: {stats[key]}", file=sys.stderr)
        sys.exit(1)
for key in ("duration_p50_ms", "duration_p90_ms", "duration_p99_ms"):
    if float(stats[key]) < 0:
        print(f"{key} negative: {stats[key]}", file=sys.stderr)
        sys.exit(1)
PY

if [ ! -s "$out_json.yaml" ]; then
	echo "YAML file was not produced"
	exit 1
fi
if ! grep -q "^stats:" "$out_json.yaml"; then
	echo "YAML output missing stats section"
	exit 1
fi

echo "Stats JSON test OK."
