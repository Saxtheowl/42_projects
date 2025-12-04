#!/usr/bin/env bash
set -euo pipefail

# Placeholder: download or point to a telemetry dataset.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$ROOT/data"
mkdir -p "$DATA_DIR"

echo "No public dataset configured. Please drop GPS/IMU traces in $DATA_DIR and name them trace01.csv, etc."
