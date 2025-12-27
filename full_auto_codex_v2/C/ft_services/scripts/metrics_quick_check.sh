#!/bin/bash
# Lightweight guard/checksums verification for existing reports.
# Usage: metrics_quick_check.sh --reports reports --suffix status_top2
set -euo pipefail

REPORTS_DIR=${REPORTS_DIR:-reports}
SUFFIX="status_top2"
SITEMAP_OPTIONAL="compare_md,compare_html,checksums_guard"
SITEMAP_STRICT=0
FAIL_ON_BADGE=""
FAIL_ON_MISSING=0
FAIL_ON_OVERALL=""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
    --reports=*) REPORTS_DIR=${1#*=}; shift ;;
    --reports) REPORTS_DIR=$2; shift 2 ;;
    --suffix=*) SUFFIX=${1#*=}; shift ;;
    --suffix) SUFFIX=$2; shift 2 ;;
    --sitemap-optional=*) SITEMAP_OPTIONAL=${1#*=}; shift ;;
    --fail-on-badge=*) FAIL_ON_BADGE=${1#*=}; shift ;;
    --fail-on-badge) FAIL_ON_BADGE=$2; shift 2 ;;
    --fail-on-missing) FAIL_ON_MISSING=1; shift ;;
    --fail-on-overall=*) FAIL_ON_OVERALL=${1#*=}; shift ;;
    --fail-on-overall) FAIL_ON_OVERALL=$2; shift 2 ;;
    --sitemap-strict) SITEMAP_STRICT=1; shift ;;
    --help)
      cat <<EOF
Usage: $0 [--reports DIR] [--suffix pattern_topN]
- Runs guard_summary CSV vs JSON consistency check if files exist.
- Verifies checksums file if present.
- Verifies sitemap JSON if present (honors --sitemap-optional, --sitemap-strict).
- Prints a concise status snapshot (badge/guard/checksums/validation/compare/sitemap/manifest/anomalies).
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

if [[ "$REPORTS_DIR" != /* ]]; then
  REPORTS_DIR="$REPO_ROOT/$REPORTS_DIR"
fi
guard_csv="$REPORTS_DIR/log_metrics_guard_summary.csv"
guard_json="$REPORTS_DIR/log_metrics_guard_summary.json"
latest_json="$REPORTS_DIR/log_metrics_latest.json"
checksums="$REPORTS_DIR/log_metrics_checksums.txt"
manifest="$REPORTS_DIR/log_metrics_manifest.json"
snapshot_csv="$REPORTS_DIR/log_metrics_snapshot.${SUFFIX}.csv"
snapshot_json="$REPORTS_DIR/log_metrics_snapshot.${SUFFIX}.json"

if [ -f "$guard_csv" ] && [ -f "$guard_json" ]; then
  echo "[quick-check] Guard summary CSV vs JSON"
  python3 "$SCRIPT_DIR/logs_metrics_guard_summary_check.py" --csv "$guard_csv" --json "$guard_json"
else
  echo "[quick-check] Guard summary files missing, skipping"
fi

if [ -f "$latest_json" ] && [ -f "$guard_json" ]; then
  echo "[quick-check] Guard summary vs latest JSON"
  python3 "$SCRIPT_DIR/logs_metrics_guard_latest_check.py" --latest "$latest_json" --guard-summary "$guard_json"
else
  echo "[quick-check] Latest or guard summary missing, skipping guard/latest check"
fi

if [ -f "$snapshot_csv" ] && [ -f "$snapshot_json" ]; then
  echo "[quick-check] Snapshot CSV vs JSON + totals"
  python3 "$SCRIPT_DIR/logs_metrics_snapshot_check.py" --csv "$snapshot_csv" --json "$snapshot_json"
else
  echo "[quick-check] Snapshot files missing, skipping"
fi

if [ -f "$checksums" ]; then
  echo "[quick-check] Verifying checksums"
  python3 "$SCRIPT_DIR/logs_metrics_verify_checksums.py" --reports "$REPORTS_DIR" --suffix "$SUFFIX" --checksums "$checksums" --manifest "$manifest"
else
  echo "[quick-check] Checksums file missing, skipping"
fi

if [ -f "$REPORTS_DIR/log_metrics_sitemap.json" ]; then
  echo "[quick-check] Verifying sitemap"
  strict_flag=""
  if [ "$SITEMAP_STRICT" = "1" ]; then
    strict_flag="--strict-summary"
  fi
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_verify.py" --reports "$REPORTS_DIR" --sitemap "$REPORTS_DIR/log_metrics_sitemap.json" --optional "$SITEMAP_OPTIONAL" $strict_flag
else
  echo "[quick-check] Sitemap JSON missing, skipping"
fi

if [ -d "$REPORTS_DIR" ]; then
  echo "[quick-check] Status snapshot"
  tmp_status="$(mktemp)"
  status_args=("--reports" "$REPORTS_DIR" "--format" "json" "--output" "$tmp_status")
  [ -n "$FAIL_ON_BADGE" ] && status_args+=("--fail-on-badge" "$FAIL_ON_BADGE")
  [ "$FAIL_ON_MISSING" = "1" ] && status_args+=("--fail-on-missing")
  python3 "$SCRIPT_DIR/logs_metrics_status.py" "${status_args[@]}" || true
  if [ -s "$tmp_status" ]; then
    # Print a concise text view for the user
    python3 "$SCRIPT_DIR/logs_metrics_status.py" --reports "$REPORTS_DIR" --format text || true
    if [ -n "$FAIL_ON_OVERALL" ]; then
      gate=$(echo "$FAIL_ON_OVERALL" | tr '[:upper:]' '[:lower:]')
      python3 - <<'PY' "$tmp_status" "$gate"
import json, sys
from pathlib import Path

status_path = Path(sys.argv[1])
gate = sys.argv[2]
order = {"ok": 0, "warn": 1, "alert": 2, "missing": 2}
try:
    data = json.loads(status_path.read_text())
    overall = str(data.get("overall_state", "n/a")).lower()
except Exception:
    overall = "n/a"
if order.get(overall, 0) >= order.get(gate, 1):
    sys.stderr.write(f"[quick-check] overall_state={overall} breaches gate ({gate})\n")
    sys.exit(1)
PY
    fi
  fi
  rm -f "$tmp_status"
fi

echo "[quick-check] Done."
