#!/bin/bash
# Thin wrapper kept for backward compatibility with earlier notes.
# USAGE: ./scripts/log_metrics_verify.sh [format] [--pattern status] [--topn 2]
set -euo pipefail

format=${1:-csv}
shift || true

export LOG_METRICS_DIR=${LOG_METRICS_DIR:-tests/env/logs}
export LC_ALL=C

./scripts/verify_snapshot.sh --format "$format" "$@"
