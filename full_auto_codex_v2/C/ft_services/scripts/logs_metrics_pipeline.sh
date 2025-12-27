#!/bin/bash
# End-to-end pipeline: export+verify snapshot, then render Markdown + HTML reports.
set -euo pipefail

PATTERN="status"
TOPN=2
LOG_DIR=${LOG_METRICS_DIR:-tests/env/logs}
REPORTS_DIR=${REPORTS_DIR:-reports}
ALERT_THRESHOLD=""
WRITE_INDEX=true
WRITE_JSONL=true
WRITE_INDEX_HTML=true
HISTORY_PATH="${REPORTS_DIR:-reports}/log_metrics_history.csv"
PRUNE_KEEP=""
WRITE_SUMMARY=true
WRITE_SUMMARY_HTML=true
WRITE_STATS=true
WRITE_PORTAL=true
WRITE_TREND_HTML=true
WRITE_STATS_HTML=true
WRITE_ANOMALIES=true
WRITE_ANOMALIES_HTML=true
ANOMALY_THRESHOLD=20
ANOMALIES_STRICT=false
WRITE_ANOMALIES_JSON=true
COMPARE_PATH=""
WRITE_MANIFEST=true
MANIFEST_HASH=true
WRITE_CHECKSUMS=true
WRITE_VERIFY_CHECKSUMS=true
WRITE_OVERVIEW=true
WRITE_OVERVIEW_HTML=true
WRITE_BUNDLE=true
WRITE_LATEST=true
WRITE_LATEST_HTML=true
WRITE_LATEST_MD=true
WRITE_RUN_SUMMARY_MD=true
WRITE_RUN_SUMMARY_HTML=true
WRITE_SITEMAP=true
WRITE_SITEMAP_HTML=true
WRITE_SITEMAP_JSON=true
FAIL_ON_MISSING_SITEMAP=false
SITEMAP_OPTIONAL="compare_md,compare_html,checksums_guard"
VERIFY_SITEMAP=true
SITEMAP_STRICT=false
SITEMAP_MANIFEST=""
SITEMAP_STATUS="skipped"
SITEMAP_JSON_PATH=""
SITEMAP_MD_PATH=""
SITEMAP_HTML_PATH=""
STATUS_JSON_PATH=""
STATUS_BADGE_PATH=""
OVERALL_STATUS=""
WRITE_BADGE=true
WRITE_STATUS_BADGE=true
FAIL_ON_OVERALL=""
RUN_VALIDATE=false
VALIDATE_MODE="full"
GUARD_CHECK_STATUS="skipped"
CHECKSUMS_STATUS="skipped"
VALIDATION_STATUS="skipped"
COMPARE_STATUS="skipped"
BADGE_WARN=50
BADGE_DANGER=80
BADGE_LABEL="metrics"
BADGE_GATE=""
WRITE_BADGE_HISTORY=true
BADGE_HISTORY_LAST=20
GUARD_DELTA_LAST=0
BADGE_OK_STREAK=0
BADGE_NO_REGRESSION=false
WRITE_GUARD_SUMMARY=true
WRITE_GUARD_CHECK=true
STATUS_BADGE_LABEL="status"
STATUS_BADGE_GATE=""
SNAPSHOT_CHECK=true
SNAPSHOT_TOLERANCE=1e-6

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

write_latest_json() {
  python3 "$SCRIPT_DIR/logs_metrics_latest.py" \
    --reports "$REPORTS_DIR" \
    --suffix "$suffix" \
    --output "${REPORTS_DIR}/log_metrics_latest.json" \
    --badge-warn "$BADGE_WARN" \
    --badge-danger "$BADGE_DANGER" \
    --badge-label "$BADGE_LABEL" \
    --badge-ok-streak "$BADGE_OK_STREAK" \
    --badge-gate "$BADGE_GATE" \
    $( [ "$BADGE_NO_REGRESSION" = true ] && echo "--badge-no-regression" ) \
    --badge-history "${REPORTS_DIR}/log_metrics_badge_history.csv" \
    --badge-history-last "$BADGE_HISTORY_LAST" \
    --badge-history-delta-last "$GUARD_DELTA_LAST"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --pattern=*) PATTERN=${1#*=}; shift ;;
    --pattern) PATTERN=$2; shift 2 ;;
    --topn=*) TOPN=${1#*=}; shift ;;
    --topn) TOPN=$2; shift 2 ;;
    --dir=*) LOG_DIR=${1#*=}; shift ;;
    --dir) LOG_DIR=$2; shift 2 ;;
    --reports=*) REPORTS_DIR=${1#*=}; shift ;;
    --reports) REPORTS_DIR=$2; shift 2 ;;
    --threshold=*) ALERT_THRESHOLD=${1#*=}; shift ;;
    --threshold) ALERT_THRESHOLD=$2; shift 2 ;;
    --no-index) WRITE_INDEX=false; shift ;;
    --no-jsonl) WRITE_JSONL=false; shift ;;
    --no-index-html) WRITE_INDEX_HTML=false; shift ;;
    --no-summary) WRITE_SUMMARY=false; shift ;;
    --no-summary-html) WRITE_SUMMARY_HTML=false; shift ;;
    --no-stats) WRITE_STATS=false; shift ;;
    --no-portal) WRITE_PORTAL=false; shift ;;
    --no-trend-html) WRITE_TREND_HTML=false; shift ;;
    --no-stats-html) WRITE_STATS_HTML=false; shift ;;
    --compare=*) COMPARE_PATH=${1#*=}; shift ;;
    --compare) COMPARE_PATH=$2; shift 2 ;;
    --no-status-badge) WRITE_STATUS_BADGE=false; shift ;;
    --status-badge-label=*) STATUS_BADGE_LABEL=${1#*=}; shift ;;
    --status-badge-label) STATUS_BADGE_LABEL=$2; shift 2 ;;
    --status-badge-gate=*) STATUS_BADGE_GATE=${1#*=}; shift ;;
    --status-badge-gate) STATUS_BADGE_GATE=$2; shift 2 ;;
    --fail-on-overall=*) FAIL_ON_OVERALL=${1#*=}; shift ;;
    --fail-on-overall) FAIL_ON_OVERALL=$2; shift 2 ;;
    --history=*) HISTORY_PATH=${1#*=}; shift ;;
    --history) HISTORY_PATH=$2; shift 2 ;;
    --prune-keep=*) PRUNE_KEEP=${1#*=}; shift ;;
    --prune-keep) PRUNE_KEEP=$2; shift 2 ;;
    --no-anomalies) WRITE_ANOMALIES=false; shift ;;
    --no-anomalies-html) WRITE_ANOMALIES_HTML=false; shift ;;
    --anomaly-threshold=*) ANOMALY_THRESHOLD=${1#*=}; shift ;;
    --anomaly-threshold) ANOMALY_THRESHOLD=$2; shift 2 ;;
    --anomalies-strict) ANOMALIES_STRICT=true; shift ;;
    --no-anomalies-json) WRITE_ANOMALIES_JSON=false; shift ;;
    --no-manifest) WRITE_MANIFEST=false; shift ;;
    --no-manifest-hash) MANIFEST_HASH=false; shift ;;
    --no-checksums) WRITE_CHECKSUMS=false; shift ;;
    --no-verify-checksums) WRITE_VERIFY_CHECKSUMS=false; shift ;;
    --no-overview) WRITE_OVERVIEW=false; shift ;;
    --no-overview-html) WRITE_OVERVIEW_HTML=false; shift ;;
    --no-bundle) WRITE_BUNDLE=false; shift ;;
    --no-latest) WRITE_LATEST=false; shift ;;
    --no-latest-html) WRITE_LATEST_HTML=false; shift ;;
    --no-latest-md) WRITE_LATEST_MD=false; shift ;;
    --no-run-summary-md) WRITE_RUN_SUMMARY_MD=false; shift ;;
    --no-run-summary-html) WRITE_RUN_SUMMARY_HTML=false; shift ;;
    --no-sitemap) WRITE_SITEMAP=false; shift ;;
    --no-sitemap-html) WRITE_SITEMAP_HTML=false; shift ;;
    --no-sitemap-json) WRITE_SITEMAP_JSON=false; shift ;;
    --fail-on-missing-sitemap) FAIL_ON_MISSING_SITEMAP=true; shift ;;
    --sitemap-optional=*) SITEMAP_OPTIONAL=${1#*=}; shift ;;
    --sitemap-manifest=*) SITEMAP_MANIFEST=${1#*=}; shift ;;
    --sitemap-strict) SITEMAP_STRICT=true; shift ;;
    --no-verify-sitemap) VERIFY_SITEMAP=false; shift ;;
    --no-badge) WRITE_BADGE=false; shift ;;
    --badge-warn=*) BADGE_WARN=${1#*=}; shift ;;
    --badge-warn) BADGE_WARN=$2; shift 2 ;;
    --badge-danger=*) BADGE_DANGER=${1#*=}; shift ;;
    --badge-danger) BADGE_DANGER=$2; shift 2 ;;
    --badge-label=*) BADGE_LABEL=${1#*=}; shift ;;
    --badge-label) BADGE_LABEL=$2; shift 2 ;;
    --badge-gate=*) BADGE_GATE=${1#*=}; shift ;;
    --badge-gate) BADGE_GATE=$2; shift 2 ;;
    --no-badge-history) WRITE_BADGE_HISTORY=false; shift ;;
    --badge-history-last=*) BADGE_HISTORY_LAST=${1#*=}; shift ;;
    --badge-history-last) BADGE_HISTORY_LAST=$2; shift 2 ;;
    --guard-delta-last=*) GUARD_DELTA_LAST=${1#*=}; shift ;;
    --guard-delta-last) GUARD_DELTA_LAST=$2; shift 2 ;;
    --post-validate) RUN_VALIDATE=true; shift ;;
    --validate-mode=*) VALIDATE_MODE=${1#*=}; shift ;;
    --validate-mode) VALIDATE_MODE=$2; shift 2 ;;
    --badge-ok-streak=*) BADGE_OK_STREAK=${1#*=}; shift ;;
    --badge-ok-streak) BADGE_OK_STREAK=$2; shift 2 ;;
    --badge-no-regression) BADGE_NO_REGRESSION=true; shift ;;
    --no-guard-summary) WRITE_GUARD_SUMMARY=false; shift ;;
    --no-guard-check) WRITE_GUARD_CHECK=false; shift ;;
    --no-snapshot-check) SNAPSHOT_CHECK=false; shift ;;
    --snapshot-tolerance=*) SNAPSHOT_TOLERANCE=${1#*=}; shift ;;
    --snapshot-tolerance) SNAPSHOT_TOLERANCE=$2; shift 2 ;;
    --help)
      cat <<EOF
Usage: $0 [--pattern NAME] [--topn N] [--dir LOG_DIR] [--reports REPORTS_DIR] [--threshold N] [--no-index] [--no-jsonl] [--no-index-html] [--no-summary] [--no-summary-html] [--no-stats] [--no-portal] [--no-trend-html] [--no-anomalies] [--anomaly-threshold N] [--history PATH] [--prune-keep N] [--compare base.csv] [--no-manifest] [--no-manifest-hash] [--no-checksums] [--no-verify-checksums] [--no-overview] [--no-overview-html] [--no-bundle] [--no-latest] [--no-latest-html] [--no-latest-md] [--no-badge] [--badge-warn N] [--badge-danger N] [--badge-label TEXT] [--badge-gate warn|alert] [--no-badge-history] [--badge-history-last N] [--guard-delta-last N] [--badge-ok-streak N] [--badge-no-regression] [--no-guard-summary]
Usage: $0 [--pattern NAME] [--topn N] [--dir LOG_DIR] [--reports REPORTS_DIR] [--threshold N] [--no-index] [--no-jsonl] [--no-index-html] [--no-summary] [--no-summary-html] [--no-stats] [--no-portal] [--no-trend-html] [--no-anomalies] [--anomaly-threshold N] [--history PATH] [--prune-keep N] [--compare base.csv] [--no-manifest] [--no-manifest-hash] [--no-checksums] [--no-verify-checksums] [--no-overview] [--no-overview-html] [--no-bundle] [--no-latest] [--no-latest-html] [--no-latest-md] [--no-badge] [--badge-warn N] [--badge-danger N] [--badge-label TEXT] [--badge-gate warn|alert] [--no-badge-history] [--badge-history-last N] [--guard-delta-last N] [--badge-ok-streak N] [--badge-no-regression] [--no-guard-summary] [--no-guard-check]
Usage: $0 ... [--post-validate] [--validate-mode full|standard|minimal]
Usage: $0 ... [--no-snapshot-check] [--snapshot-tolerance 1e-6]
Usage: $0 ... [--sitemap-optional names] [--sitemap-manifest path] [--sitemap-strict] [--fail-on-missing-sitemap]
Runs verify_snapshot (CSV+JSON), then renders Markdown and HTML reports from the CSV, optionally enforces an overload ratio threshold, writes summary (md+html)/history/trend (md+html)/stats (md+html)/anomalies (md+html+json), optional compare (md+html), index (md/html), portal, overview (md+html), latest summary (json+html+md), badge SVG (customizable thresholds/label), optional badge gate (warn/alert), OK streak guard, regression guard, badge history CSV/md/html, manifest JSON (with sha256 unless disabled), bundle tar.gz, checksums file, and prunes old snapshots.
Guard summary: generates md/html/json/csv (unless --no-guard-summary) and checks CSV vs JSON consistency unless --no-guard-check.
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

cd "$REPO_ROOT"

if [[ "$LOG_DIR" != /* ]]; then
  LOG_DIR="$REPO_ROOT/$LOG_DIR"
fi
if [[ "$REPORTS_DIR" != /* ]]; then
  REPORTS_DIR="$REPO_ROOT/$REPORTS_DIR"
fi
STATUS_JSON_PATH="${REPORTS_DIR}/log_metrics_status.json"
STATUS_BADGE_PATH="${REPORTS_DIR}/log_metrics_status_badge.svg"
OVERALL_STATUS="n/a"

if [ ! -d "$LOG_DIR" ]; then
  echo "Log directory $LOG_DIR not found" >&2
  exit 1
fi

mkdir -p "$REPORTS_DIR"
pattern_label=$(printf "%s" "$PATTERN" | tr -cs '[:alnum:]_-' '_')
top_label=${TOPN#-}
suffix="top${top_label}"
[ -n "$pattern_label" ] && suffix="${pattern_label}_${suffix}"
base="${REPORTS_DIR}/log_metrics_snapshot.${suffix}"

echo "[1/3] Verifying snapshot (CSV+JSON)"
$SCRIPT_DIR/verify_snapshot.sh --format both --pattern "$PATTERN" --topn "$TOPN" --dir "$LOG_DIR" --reports "$REPORTS_DIR"
if [ "$SNAPSHOT_CHECK" = true ]; then
  echo "[1b/3] Deep snapshot check (CSV vs JSON, totals/ratios)"
  python3 "$SCRIPT_DIR/logs_metrics_snapshot_check.py" --reports "$REPORTS_DIR" --suffix "$suffix" --tolerance "$SNAPSHOT_TOLERANCE"
fi

csv_path="${base}.csv"
html_path="${base}.html"
md_path="${base}.md"

if [ ! -f "$csv_path" ]; then
  echo "CSV snapshot not found at $csv_path" >&2
  exit 1
fi

echo "[2/3] Rendering Markdown report -> ${md_path}"
$SCRIPT_DIR/logs_metrics_report.sh --input "$csv_path" --output "$md_path"

echo "[3/3] Rendering HTML report -> ${html_path}"
python3 "$SCRIPT_DIR/logs_metrics_report_html.py" --input "$csv_path" --output "$html_path"

if [ -n "$ALERT_THRESHOLD" ]; then
  echo "[alert] Checking overloaded_ratio <= ${ALERT_THRESHOLD}%"
  python3 "$SCRIPT_DIR/logs_metrics_alerts.py" --input "$csv_path" --threshold "$ALERT_THRESHOLD"
fi

if [ "$WRITE_JSONL" = true ]; then
  echo "[jsonl] Exporting JSONL"
  python3 "$SCRIPT_DIR/logs_metrics_snapshot_to_jsonl.py" --input "$csv_path" --output "${base}.jsonl"
fi

if [ "$WRITE_SUMMARY" = true ]; then
  echo "[summary] Writing summary report"
  python3 "$SCRIPT_DIR/logs_metrics_summary.py" --input "$csv_path" --output "${base}.summary.md"
  if [ "$WRITE_SUMMARY_HTML" = true ]; then
    echo "[summary-html] Writing summary HTML"
    python3 "$SCRIPT_DIR/logs_metrics_summary_html.py" --input "$csv_path" --output "${base}.summary.html"
  fi
fi

echo "[history] Appending snapshot summary"
python3 "$SCRIPT_DIR/logs_metrics_history.py" --input "$csv_path" --pattern "$PATTERN" --topn "$TOPN" --history "$HISTORY_PATH"

if [ -f "$HISTORY_PATH" ]; then
  echo "[trend] Rendering trend report"
  python3 "$SCRIPT_DIR/logs_metrics_trend.py" --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_trend.md"
  if [ "$WRITE_TREND_HTML" = true ]; then
    echo "[trend-html] Rendering trend HTML"
    python3 "$SCRIPT_DIR/logs_metrics_trend_html.py" --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_trend.html"
  fi
  if [ "$WRITE_STATS" = true ]; then
    echo "[stats] Computing history stats"
    python3 "$SCRIPT_DIR/logs_metrics_stats.py" --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_stats.md"
    if [ "$WRITE_STATS_HTML" = true ]; then
      echo "[stats-html] Rendering stats HTML"
      python3 "$SCRIPT_DIR/logs_metrics_stats_html.py" --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_stats.html"
    fi
  fi
  if [ "$WRITE_ANOMALIES" = true ]; then
    echo "[anomalies] Computing anomalies"
    python3 "$SCRIPT_DIR/logs_metrics_anomalies.py" --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_anomalies.md" --json-output "${REPORTS_DIR}/log_metrics_anomalies.json" --threshold "$ANOMALY_THRESHOLD" $( [ "$ANOMALIES_STRICT" = true ] && echo "--strict" )
    if [ "$WRITE_ANOMALIES_HTML" = true ]; then
      echo "[anomalies-html] Rendering anomalies HTML"
      python3 "$SCRIPT_DIR/logs_metrics_anomalies_html.py" --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_anomalies.html" --threshold "$ANOMALY_THRESHOLD"
    fi
    if [ "$WRITE_ANOMALIES_JSON" != true ]; then
      rm -f "${REPORTS_DIR}/log_metrics_anomalies.json"
    fi
  fi
fi

if [ "$WRITE_OVERVIEW" = true ]; then
  echo "[overview] Writing overview"
  python3 "$SCRIPT_DIR/logs_metrics_overview.py" --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_overview.md"
fi

if [ "$WRITE_OVERVIEW_HTML" = true ]; then
  echo "[overview-html] Writing overview HTML"
  python3 "$SCRIPT_DIR/logs_metrics_overview_html.py" --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_overview.html"
fi

if [ "$WRITE_LATEST" = true ]; then
  echo "[latest] Writing latest JSON summary"
  write_latest_json
fi

if [ "$WRITE_BADGE" = true ]; then
  echo "[badge] Writing badge SVG"
  python3 "$SCRIPT_DIR/logs_metrics_badge.py" --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_badge.svg" --warn-overloaded-ratio "$BADGE_WARN" --danger-overloaded-ratio "$BADGE_DANGER" --label "$BADGE_LABEL"
fi

if [ "$WRITE_BADGE_HISTORY" = true ]; then
  echo "[badge-history] Appending badge history"
  python3 "$SCRIPT_DIR/logs_metrics_badge_history.py" --latest "${REPORTS_DIR}/log_metrics_latest.json" --output "${REPORTS_DIR}/log_metrics_badge_history.csv"
  python3 "$SCRIPT_DIR/logs_metrics_badge_history_md.py" --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_badge_history.md" --last "$BADGE_HISTORY_LAST"
  python3 "$SCRIPT_DIR/logs_metrics_badge_history_html.py" --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_badge_history.html" --last "$BADGE_HISTORY_LAST"
  if [ "$WRITE_GUARD_SUMMARY" = true ]; then
    echo "[guard-summary] Writing guard summary"
    python3 "$SCRIPT_DIR/logs_metrics_guard_summary.py" --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_guard_summary.md" --last "$BADGE_HISTORY_LAST" --delta-last "$GUARD_DELTA_LAST"
    python3 "$SCRIPT_DIR/logs_metrics_guard_summary_html.py" --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_guard_summary.html" --last "$BADGE_HISTORY_LAST" --delta-last "$GUARD_DELTA_LAST"
    python3 "$SCRIPT_DIR/logs_metrics_guard_summary_json.py" --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_guard_summary.json" --last "$BADGE_HISTORY_LAST" --delta-last "$GUARD_DELTA_LAST"
    python3 "$SCRIPT_DIR/logs_metrics_guard_summary_csv.py" --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_guard_summary.csv" --last "$BADGE_HISTORY_LAST" --delta-last "$GUARD_DELTA_LAST"
  fi
fi

if [ "$WRITE_GUARD_CHECK" = true ] && [ "$WRITE_GUARD_SUMMARY" = true ]; then
  if [ -f "${REPORTS_DIR}/log_metrics_guard_summary.csv" ] && [ -f "${REPORTS_DIR}/log_metrics_guard_summary.json" ]; then
    echo "[guard-check] Checking guard_summary CSV vs JSON"
    python3 "$SCRIPT_DIR/logs_metrics_guard_summary_check.py" --csv "${REPORTS_DIR}/log_metrics_guard_summary.csv" --json "${REPORTS_DIR}/log_metrics_guard_summary.json"
    GUARD_CHECK_STATUS="ok"
  else
    echo "[guard-check] Skip (guard_summary files missing)"
    GUARD_CHECK_STATUS="skipped"
  fi
fi

if [ "$WRITE_LATEST" = true ] && [ "$WRITE_BADGE_HISTORY" = true ]; then
  echo "[latest] Refreshing latest JSON summary with badge history"
  write_latest_json
fi

if [ "$WRITE_GUARD_CHECK" = true ] && [ "$WRITE_GUARD_SUMMARY" = true ] && [ "$WRITE_LATEST" = true ]; then
  if [ -f "${REPORTS_DIR}/log_metrics_guard_summary.json" ] && [ -f "${REPORTS_DIR}/log_metrics_latest.json" ]; then
    echo "[guard-check] Checking guard_summary vs latest JSON"
    python3 "$SCRIPT_DIR/logs_metrics_guard_latest_check.py" --latest "${REPORTS_DIR}/log_metrics_latest.json" --guard-summary "${REPORTS_DIR}/log_metrics_guard_summary.json"
    GUARD_CHECK_STATUS="ok"
  else
    echo "[guard-check] Skip (latest or guard_summary missing)"
    GUARD_CHECK_STATUS="skipped"
  fi
fi

if [ "$WRITE_LATEST_HTML" = true ]; then
  echo "[latest-html] Writing latest HTML summary"
  python3 "$SCRIPT_DIR/logs_metrics_latest_html.py" --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_latest.html" --badge-warn "$BADGE_WARN" --badge-danger "$BADGE_DANGER" --badge-label "$BADGE_LABEL"
fi

if [ "$WRITE_LATEST_MD" = true ]; then
  echo "[latest-md] Writing latest Markdown summary"
  python3 "$SCRIPT_DIR/logs_metrics_latest_md.py" --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_latest.md" --badge-warn "$BADGE_WARN" --badge-danger "$BADGE_DANGER" --badge-label "$BADGE_LABEL"
fi

if [ -n "$BADGE_GATE" ]; then
  if [ "$WRITE_LATEST" != true ]; then
    echo "[badge-gate] Requires latest JSON (enable --latest)" >&2
    exit 1
  fi
  echo "[badge-gate] Enforcing badge gate (${BADGE_GATE})"
  python3 - "$REPORTS_DIR" "$BADGE_GATE" <<'PY'
import json, sys
from pathlib import Path
reports = Path(sys.argv[1])
gate = sys.argv[2].lower()
allowed = {"warn", "alert"}
if gate not in allowed:
    print(f"[badge-gate] unknown gate '{gate}' (expected warn|alert)", file=sys.stderr)
    sys.exit(1)
latest_path = reports / "log_metrics_latest.json"
if not latest_path.exists():
    print(f"[badge-gate] missing latest JSON at {latest_path}", file=sys.stderr)
    sys.exit(1)
data = json.loads(latest_path.read_text())
state = str(data.get("badge_state", "ok")).lower()
order = {"ok": 0, "warn": 1, "alert": 2}
gate_order = order[gate]
state_order = order.get(state, 0)
if state_order >= gate_order:
    print(f"[badge-gate] FAIL: state={state} (gate={gate})", file=sys.stderr)
    sys.exit(1)
print(f"[badge-gate] OK: state={state} (gate={gate})")
PY
fi

if [ "$BADGE_OK_STREAK" -gt 0 ]; then
  echo "[badge-ok-streak] Enforcing minimum OK streak (${BADGE_OK_STREAK})"
  python3 - "$REPORTS_DIR" "$BADGE_OK_STREAK" <<'PY'
import json, sys
from pathlib import Path
reports = Path(sys.argv[1])
min_streak = int(sys.argv[2])
latest_path = reports / "log_metrics_latest.json"
if not latest_path.exists():
    print(f"[badge-ok-streak] missing latest JSON at {latest_path}", file=sys.stderr)
    sys.exit(1)
data = json.loads(latest_path.read_text())
history = data.get("badge_history") or {}
current = history.get("current_streak") or {}
state = str(current.get("state", "")).lower()
length = int(current.get("length", 0) or 0)
if state != "ok" or length < min_streak:
    print(f"[badge-ok-streak] FAIL: state={state}, streak={length}, required ok>={min_streak}", file=sys.stderr)
    sys.exit(1)
print(f"[badge-ok-streak] OK: state={state}, streak={length} (>= {min_streak})")
PY
fi

if [ "$BADGE_NO_REGRESSION" = true ]; then
  echo "[badge-no-regression] Checking regression vs previous badge state"
  python3 - "$REPORTS_DIR" <<'PY'
import json, sys, csv
from pathlib import Path
reports = Path(sys.argv[1])
latest_path = reports / "log_metrics_latest.json"
history_path = reports / "log_metrics_badge_history.csv"
if not latest_path.exists() or not history_path.exists():
    print("[badge-no-regression] missing latest or history, skipping", file=sys.stderr)
    sys.exit(0)
data = json.loads(latest_path.read_text())
state = str(data.get("badge_state", "ok")).lower()
order = {"ok": 0, "warn": 1, "alert": 2}
if state not in order:
    print("[badge-no-regression] unknown state, skipping", file=sys.stderr)
    sys.exit(0)
with history_path.open(newline="") as f:
    rows = list(csv.DictReader(f))
if len(rows) < 2:
    sys.exit(0)
prev = rows[-2]
prev_state = str(prev.get("badge_state", "ok")).lower()
if order.get(state, 0) > order.get(prev_state, 0):
    print(f"[badge-no-regression] FAIL: regression from {prev_state} to {state}", file=sys.stderr)
    sys.exit(1)
print(f"[badge-no-regression] OK: state={state}, previous={prev_state}")
PY
fi

if [ "$WRITE_INDEX" = true ]; then
  echo "[index] Writing reports index"
  python3 "$SCRIPT_DIR/logs_metrics_index.py" --reports "$REPORTS_DIR" --suffix "$suffix"
  if [ "$WRITE_INDEX_HTML" = true ]; then
    python3 "$SCRIPT_DIR/logs_metrics_index_html.py" --reports "$REPORTS_DIR" --suffix "$suffix"
  fi
fi

checksum_path="${REPORTS_DIR}/log_metrics_checksums.txt"
manifest_path="${REPORTS_DIR}/log_metrics_manifest.json"
if [ "$WRITE_CHECKSUMS" = true ]; then
  # Pre-create the checksums file so the manifest can reference it with exists=true
  mkdir -p "$REPORTS_DIR"
  : > "$checksum_path"
fi

if [ -n "$COMPARE_PATH" ]; then
  if [ ! -f "$COMPARE_PATH" ]; then
    echo "[compare] Base file $COMPARE_PATH not found" >&2
    exit 1
  fi
  echo "[compare] Writing diff vs $COMPARE_PATH"
  python3 "$SCRIPT_DIR/logs_metrics_compare.py" --base "$COMPARE_PATH" --target "$csv_path" --output "${REPORTS_DIR}/log_metrics_compare.md"
  python3 "$SCRIPT_DIR/logs_metrics_compare_html.py" --base "$COMPARE_PATH" --target "$csv_path" --output "${REPORTS_DIR}/log_metrics_compare.html"
  COMPARE_STATUS="ok"
fi

if [ -n "$PRUNE_KEEP" ]; then
  echo "[prune] Keeping latest ${PRUNE_KEEP} snapshots per extension"
  "$SCRIPT_DIR/logs_metrics_prune_reports.sh" --reports "$REPORTS_DIR" --suffix "$suffix" --keep "$PRUNE_KEEP"
fi

if [ "$WRITE_CHECKSUMS" = true ] && [ "$WRITE_VERIFY_CHECKSUMS" = true ]; then
  CHECKSUMS_STATUS="ok"
fi

# First run summary before validation (captures current statuses)
if [ "$WRITE_LATEST" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary.py" \
    --reports "$REPORTS_DIR" \
    --suffix "$suffix" \
    --latest "${REPORTS_DIR}/log_metrics_latest.json" \
    --guard-check "$GUARD_CHECK_STATUS" \
    --checksums "$CHECKSUMS_STATUS" \
    --validation "$VALIDATION_STATUS" \
    --validation-mode "$VALIDATE_MODE" \
    --compare-status "$COMPARE_STATUS" \
    --compare-md "${REPORTS_DIR}/log_metrics_compare.md" \
    --compare-html "${REPORTS_DIR}/log_metrics_compare.html" \
    --manifest "${REPORTS_DIR}/log_metrics_manifest.json" \
    --bundle "${REPORTS_DIR}/log_metrics_bundle.tar.gz" \
    --checksums-path "$checksum_path" \
    --portal "${REPORTS_DIR}/portal.html" \
    --index "${REPORTS_DIR}/index.md" \
    --status-json "$STATUS_JSON_PATH" \
    --include-manifest-from-status \
    --status-overall "$OVERALL_STATUS" \
    --sitemap-status "$SITEMAP_STATUS" \
    --sitemap-json "$SITEMAP_JSON_PATH" \
    --sitemap-md "$SITEMAP_MD_PATH" \
    --sitemap-html "$SITEMAP_HTML_PATH" \
    --status-badge "$STATUS_BADGE_PATH" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.json"
fi

if [ "$WRITE_RUN_SUMMARY_MD" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary_md.py" \
    --reports "$REPORTS_DIR" \
    --run-summary "${REPORTS_DIR}/log_metrics_run_summary.json" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.md"
fi

if [ "$WRITE_RUN_SUMMARY_HTML" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary_html.py" \
    --reports "$REPORTS_DIR" \
    --run-summary "${REPORTS_DIR}/log_metrics_run_summary.json" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.html"
fi

if [ "$WRITE_PORTAL" = true ]; then
  echo "[portal] Writing portal (pre-validation)"
  python3 "$SCRIPT_DIR/logs_metrics_portal.py" --reports "$REPORTS_DIR" --suffix "$suffix"
fi

if [ "$WRITE_BUNDLE" = true ]; then
  echo "[bundle] Creating bundle (pre-validation)"
  bash "$SCRIPT_DIR/logs_metrics_publish.sh" --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_bundle.tar.gz"
fi

if [ "$WRITE_MANIFEST" = true ]; then
  echo "[manifest] Writing manifest (pre-validation)"
  manifest_args=(
    --reports "$REPORTS_DIR"
    --suffix "$suffix"
    --output "${REPORTS_DIR}/log_metrics_manifest.json"
  )
  [ "$MANIFEST_HASH" = false ] && manifest_args+=(--no-sha256)
  python3 "$SCRIPT_DIR/logs_metrics_manifest.py" "${manifest_args[@]}"
fi

if [ "$WRITE_CHECKSUMS" = true ]; then
  echo "[checksums] Generating checksums (pre-validation)"
  "$SCRIPT_DIR/logs_metrics_checksums.sh" --reports "$REPORTS_DIR" --suffix "$suffix" --output "$checksum_path"
fi

if [ "$WRITE_VERIFY_CHECKSUMS" = true ]; then
  echo "[verify-checksums] Verifying checksums (pre-validation)"
  (cd "$REPORTS_DIR" && sha256sum --check "$(basename "$checksum_path")")
fi

if [ "$RUN_VALIDATE" = true ]; then
  echo "[validate] Running post-pipeline validation (mode=${VALIDATE_MODE})"
  python3 "$SCRIPT_DIR/logs_metrics_validate.py" --reports "$REPORTS_DIR" --suffix "$suffix" --mode "$VALIDATE_MODE"
  VALIDATION_STATUS="ok"
else
  VALIDATION_STATUS="skipped"
fi

# Refresh artifacts to embed validation status in the run summary and derived assets
if [ "$WRITE_LATEST" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary.py" \
    --reports "$REPORTS_DIR" \
    --suffix "$suffix" \
    --latest "${REPORTS_DIR}/log_metrics_latest.json" \
    --guard-check "$GUARD_CHECK_STATUS" \
    --checksums "$CHECKSUMS_STATUS" \
    --validation "$VALIDATION_STATUS" \
    --validation-mode "$VALIDATE_MODE" \
    --compare-status "$COMPARE_STATUS" \
    --compare-md "${REPORTS_DIR}/log_metrics_compare.md" \
    --compare-html "${REPORTS_DIR}/log_metrics_compare.html" \
    --manifest "${REPORTS_DIR}/log_metrics_manifest.json" \
    --bundle "${REPORTS_DIR}/log_metrics_bundle.tar.gz" \
    --checksums-path "$checksum_path" \
    --portal "${REPORTS_DIR}/portal.html" \
    --index "${REPORTS_DIR}/index.md" \
    --status-json "$STATUS_JSON_PATH" \
    --include-manifest-from-status \
    --status-overall "$OVERALL_STATUS" \
    --status-badge "$STATUS_BADGE_PATH" \
    --sitemap-status "$SITEMAP_STATUS" \
    --sitemap-json "$SITEMAP_JSON_PATH" \
    --sitemap-md "$SITEMAP_MD_PATH" \
    --sitemap-html "$SITEMAP_HTML_PATH" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.json"
fi

if [ "$WRITE_RUN_SUMMARY_MD" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary_md.py" \
    --reports "$REPORTS_DIR" \
    --run-summary "${REPORTS_DIR}/log_metrics_run_summary.json" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.md"
fi

if [ "$WRITE_PORTAL" = true ]; then
  echo "[portal] Writing portal"
  python3 "$SCRIPT_DIR/logs_metrics_portal.py" --reports "$REPORTS_DIR" --suffix "$suffix"
fi

# Write a concise status snapshot (JSON) for automation/reporting (before final manifest/sitemap/checksums)
STATUS_JSON_PATH="${REPORTS_DIR}/log_metrics_status.json"
STATUS_BADGE_PATH=""
OVERALL_STATUS="n/a"
OVERALL_HISTORY_PATH="${REPORTS_DIR}/log_metrics_overall_history.csv"
if python3 "$SCRIPT_DIR/logs_metrics_status.py" --reports "$REPORTS_DIR" --format json --optional "$SITEMAP_OPTIONAL" --output "$STATUS_JSON_PATH"; then
  if [ -s "$STATUS_JSON_PATH" ]; then
    OVERALL_STATUS=$(python3 - "$STATUS_JSON_PATH" <<'PY'
import json, sys
from pathlib import Path
path = Path(sys.argv[1])
try:
    data = json.loads(path.read_text())
    print(data.get("overall_state", "n/a"))
except Exception:
    print("n/a")
PY
)
    if [ "$WRITE_STATUS_BADGE" = true ]; then
      STATUS_BADGE_PATH="${REPORTS_DIR}/log_metrics_status_badge.svg"
      python3 "$SCRIPT_DIR/logs_metrics_status_badge.py" --status-json "$STATUS_JSON_PATH" --output "$STATUS_BADGE_PATH" --label "$STATUS_BADGE_LABEL" $( [ -n "$STATUS_BADGE_GATE" ] && echo --gate "$STATUS_BADGE_GATE" )
    fi
    python3 "$SCRIPT_DIR/logs_metrics_overall_history.py" --status-json "$STATUS_JSON_PATH" --output "$OVERALL_HISTORY_PATH" --keep-last 200 || true
  fi
else
  echo "[status] Warning: status generation failed (continuing with overall=n/a)" >&2
fi
# Optional gate on overall status
if [ -n "$FAIL_ON_OVERALL" ]; then
  order_ok=0; order_warn=1; order_alert=2
  case "$FAIL_ON_OVERALL" in
    warn) gate_order=$order_warn ;;
    alert) gate_order=$order_alert ;;
    *) gate_order=$order_warn ;;
  esac
  state_norm=$(echo "$OVERALL_STATUS" | tr '[:upper:]' '[:lower:]')
  case "$state_norm" in
    ok) state_order=$order_ok ;;
    warn) state_order=$order_warn ;;
    alert|missing) state_order=$order_alert ;;
    *) state_order=$order_ok ;;
  esac
  if [ "$state_order" -ge "$gate_order" ]; then
    echo "[status] overall_state=$OVERALL_STATUS breaches gate ($FAIL_ON_OVERALL)" >&2
    exit 1
  fi
fi

if [ "$WRITE_BUNDLE" = true ]; then
  echo "[bundle] Creating bundle"
  bash "$SCRIPT_DIR/logs_metrics_publish.sh" --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_bundle.tar.gz"
fi

if [ "$WRITE_MANIFEST" = true ]; then
  echo "[manifest] Writing manifest"
  manifest_args=(
    --reports "$REPORTS_DIR"
    --suffix "$suffix"
    --output "${REPORTS_DIR}/log_metrics_manifest.json"
  )
  [ "$MANIFEST_HASH" = false ] && manifest_args+=(--no-sha256)
  python3 "$SCRIPT_DIR/logs_metrics_manifest.py" "${manifest_args[@]}"
fi

if [ "$WRITE_CHECKSUMS" = true ]; then
  echo "[checksums] Regenerating checksums after validation"
  "$SCRIPT_DIR/logs_metrics_checksums.sh" --reports "$REPORTS_DIR" --suffix "$suffix" --output "$checksum_path"
fi

if [ "$WRITE_VERIFY_CHECKSUMS" = true ]; then
  echo "[verify-checksums] Verifying final checksums"
  (cd "$REPORTS_DIR" && sha256sum --check "$(basename "$checksum_path")")
fi

if [ "$WRITE_SITEMAP" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_md.py" \
    --reports "$REPORTS_DIR" \
    --manifest "${REPORTS_DIR}/log_metrics_manifest.json" \
    --output "${REPORTS_DIR}/log_metrics_sitemap.md" \
    --optional "$SITEMAP_OPTIONAL"
  SITEMAP_MD_PATH="${REPORTS_DIR}/log_metrics_sitemap.md"
fi

if [ "$WRITE_SITEMAP_HTML" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_html.py" \
    --reports "$REPORTS_DIR" \
    --manifest "${REPORTS_DIR}/log_metrics_manifest.json" \
    --output "${REPORTS_DIR}/log_metrics_sitemap.html" \
    --optional "$SITEMAP_OPTIONAL"
  SITEMAP_HTML_PATH="${REPORTS_DIR}/log_metrics_sitemap.html"
fi

if [ "$WRITE_SITEMAP_JSON" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_json.py" \
    --reports "$REPORTS_DIR" \
    --manifest "${REPORTS_DIR}/log_metrics_manifest.json" \
    --output "${REPORTS_DIR}/log_metrics_sitemap.json" \
    --optional "$SITEMAP_OPTIONAL" \
    $( [ "$FAIL_ON_MISSING_SITEMAP" = true ] && echo "--fail-on-missing" )
  SITEMAP_JSON_PATH="${REPORTS_DIR}/log_metrics_sitemap.json"
fi

if [ "$VERIFY_SITEMAP" = true ] && [ -f "${REPORTS_DIR}/log_metrics_sitemap.json" ]; then
  echo "[sitemap] Verifying sitemap JSON"
  manifest_arg=""
  if [ -n "$SITEMAP_MANIFEST" ]; then
    manifest_arg="--manifest $SITEMAP_MANIFEST"
  else
    manifest_arg="--manifest ${REPORTS_DIR}/log_metrics_manifest.json"
  fi
  strict_arg=""
  if [ "$SITEMAP_STRICT" = true ]; then
    strict_arg="--strict-summary"
  fi
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_verify.py" --reports "$REPORTS_DIR" --sitemap "${REPORTS_DIR}/log_metrics_sitemap.json" --optional "$SITEMAP_OPTIONAL" $strict_arg $manifest_arg
  SITEMAP_STATUS="ok"
fi

if [ "$RUN_VALIDATE" = true ]; then
  echo "[validate] Re-running validation to confirm refreshed artifacts"
  python3 "$SCRIPT_DIR/logs_metrics_validate.py" --reports "$REPORTS_DIR" --suffix "$suffix" --mode "$VALIDATE_MODE"
  VALIDATION_STATUS="ok"
fi

# Final run summary after sitemap/checksums/validation
if [ "$WRITE_LATEST" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary.py" \
    --reports "$REPORTS_DIR" \
    --suffix "$suffix" \
    --latest "${REPORTS_DIR}/log_metrics_latest.json" \
    --guard-check "$GUARD_CHECK_STATUS" \
    --checksums "$CHECKSUMS_STATUS" \
    --validation "$VALIDATION_STATUS" \
    --validation-mode "$VALIDATE_MODE" \
    --compare-status "$COMPARE_STATUS" \
    --compare-md "${REPORTS_DIR}/log_metrics_compare.md" \
    --compare-html "${REPORTS_DIR}/log_metrics_compare.html" \
    --manifest "${REPORTS_DIR}/log_metrics_manifest.json" \
    --bundle "${REPORTS_DIR}/log_metrics_bundle.tar.gz" \
    --checksums-path "$checksum_path" \
    --portal "${REPORTS_DIR}/portal.html" \
    --index "${REPORTS_DIR}/index.md" \
    --status-json "$STATUS_JSON_PATH" \
    --include-manifest-from-status \
    --status-overall "$OVERALL_STATUS" \
    --status-badge "$STATUS_BADGE_PATH" \
    --sitemap-status "$SITEMAP_STATUS" \
    --sitemap-json "$SITEMAP_JSON_PATH" \
    --sitemap-md "$SITEMAP_MD_PATH" \
    --sitemap-html "$SITEMAP_HTML_PATH" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.json"
fi

if [ "$WRITE_RUN_SUMMARY_MD" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary_md.py" \
    --reports "$REPORTS_DIR" \
    --run-summary "${REPORTS_DIR}/log_metrics_run_summary.json" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.md"
fi

if [ "$WRITE_RUN_SUMMARY_HTML" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary_html.py" \
    --reports "$REPORTS_DIR" \
    --run-summary "${REPORTS_DIR}/log_metrics_run_summary.json" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.html"
fi

if [ "$WRITE_INDEX" = true ]; then
  echo "[index] Refreshing reports index (post-run-summary)"
  python3 "$SCRIPT_DIR/logs_metrics_index.py" --reports "$REPORTS_DIR" --suffix "$suffix"
  if [ "$WRITE_INDEX_HTML" = true ]; then
    python3 "$SCRIPT_DIR/logs_metrics_index_html.py" --reports "$REPORTS_DIR" --suffix "$suffix"
  fi
fi

if [ "$WRITE_MANIFEST" = true ]; then
  echo "[manifest] Writing manifest (post-index)"
  python3 "$SCRIPT_DIR/logs_metrics_manifest.py" --reports "$REPORTS_DIR" --suffix "$suffix" --output "$manifest_path" $( [ "$MANIFEST_HASH" = false ] && echo "--no-hash" )
fi

# Rebuild sitemap from the final manifest to keep summaries in sync
if [ "$WRITE_SITEMAP" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_md.py" \
    --reports "$REPORTS_DIR" \
    --manifest "$manifest_path" \
    --output "${REPORTS_DIR}/log_metrics_sitemap.md" \
    --optional "$SITEMAP_OPTIONAL"
  SITEMAP_MD_PATH="${REPORTS_DIR}/log_metrics_sitemap.md"
fi

if [ "$WRITE_SITEMAP_HTML" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_html.py" \
    --reports "$REPORTS_DIR" \
    --manifest "$manifest_path" \
    --output "${REPORTS_DIR}/log_metrics_sitemap.html" \
    --optional "$SITEMAP_OPTIONAL"
  SITEMAP_HTML_PATH="${REPORTS_DIR}/log_metrics_sitemap.html"
fi

if [ "$WRITE_SITEMAP_JSON" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_json.py" \
    --reports "$REPORTS_DIR" \
    --manifest "$manifest_path" \
    --output "${REPORTS_DIR}/log_metrics_sitemap.json" \
    --optional "$SITEMAP_OPTIONAL" \
    $( [ "$FAIL_ON_MISSING_SITEMAP" = true ] && echo "--fail-on-missing" )
  SITEMAP_JSON_PATH="${REPORTS_DIR}/log_metrics_sitemap.json"
fi

if [ "$VERIFY_SITEMAP" = true ] && [ -f "${REPORTS_DIR}/log_metrics_sitemap.json" ]; then
  echo "[sitemap] Verifying sitemap JSON (post-manifest)"
  manifest_arg=""
  if [ -n "$SITEMAP_MANIFEST" ]; then
    manifest_arg="--manifest $SITEMAP_MANIFEST"
  else
    manifest_arg="--manifest $manifest_path"
  fi
  strict_arg=""
  if [ "$SITEMAP_STRICT" = true ]; then
    strict_arg="--strict-summary"
  fi
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_verify.py" --reports "$REPORTS_DIR" --sitemap "${REPORTS_DIR}/log_metrics_sitemap.json" --optional "$SITEMAP_OPTIONAL" $strict_arg $manifest_arg
  SITEMAP_STATUS="ok"
fi

if [ "$RUN_VALIDATE" = true ]; then
  echo "[validate] Final validation after sitemap refresh (mode=${VALIDATE_MODE})"
  python3 "$SCRIPT_DIR/logs_metrics_validate.py" --reports "$REPORTS_DIR" --suffix "$suffix" --mode "$VALIDATE_MODE"
  VALIDATION_STATUS="ok"
fi

if [ "$WRITE_INDEX" = true ]; then
  echo "[index] Refreshing reports index (final pass)"
  python3 "$SCRIPT_DIR/logs_metrics_index.py" --reports "$REPORTS_DIR" --suffix "$suffix"
  if [ "$WRITE_INDEX_HTML" = true ]; then
    python3 "$SCRIPT_DIR/logs_metrics_index_html.py" --reports "$REPORTS_DIR" --suffix "$suffix"
  fi
fi

if [ "$WRITE_PORTAL" = true ]; then
  echo "[portal] Writing portal (final pass)"
  python3 "$SCRIPT_DIR/logs_metrics_portal.py" --reports "$REPORTS_DIR" --suffix "$suffix"
fi

# Refresh status snapshot after the final manifest/sitemap to keep overall_state aligned
if python3 "$SCRIPT_DIR/logs_metrics_status.py" --reports "$REPORTS_DIR" --format json --optional "$SITEMAP_OPTIONAL" --output "$STATUS_JSON_PATH"; then
  if [ -s "$STATUS_JSON_PATH" ]; then
    OVERALL_STATUS=$(python3 - "$STATUS_JSON_PATH" <<'PY'
import json, sys
from pathlib import Path
path = Path(sys.argv[1])
try:
    data = json.loads(path.read_text())
    print(data.get("overall_state", "n/a"))
except Exception:
    print("n/a")
PY
)
    if [ "$WRITE_STATUS_BADGE" = true ]; then
      STATUS_BADGE_PATH="${REPORTS_DIR}/log_metrics_status_badge.svg"
      python3 "$SCRIPT_DIR/logs_metrics_status_badge.py" --status-json "$STATUS_JSON_PATH" --output "$STATUS_BADGE_PATH" --label "$STATUS_BADGE_LABEL" $( [ -n "$STATUS_BADGE_GATE" ] && echo --gate "$STATUS_BADGE_GATE" )
    fi
  fi
else
  echo "[status] Warning: final status generation failed (keeping previous overall_state=$OVERALL_STATUS)" >&2
fi

if [ "$WRITE_MANIFEST" = true ]; then
  echo "[manifest] Writing manifest (final pass)"
  python3 "$SCRIPT_DIR/logs_metrics_manifest.py" --reports "$REPORTS_DIR" --suffix "$suffix" --output "$manifest_path" $( [ "$MANIFEST_HASH" = false ] && echo "--no-hash" )
fi

# Refresh sitemap once more to align with the final manifest (after index/portal)
if [ "$WRITE_SITEMAP_JSON" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_sitemap_json.py" \
    --reports "$REPORTS_DIR" \
    --manifest "$manifest_path" \
    --output "${REPORTS_DIR}/log_metrics_sitemap.json" \
    --optional "$SITEMAP_OPTIONAL" \
    $( [ "$FAIL_ON_MISSING_SITEMAP" = true ] && echo "--fail-on-missing" )
  SITEMAP_JSON_PATH="${REPORTS_DIR}/log_metrics_sitemap.json"
fi

if [ "$WRITE_LATEST" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary.py" \
    --reports "$REPORTS_DIR" \
    --suffix "$suffix" \
    --latest "${REPORTS_DIR}/log_metrics_latest.json" \
    --guard-check "$GUARD_CHECK_STATUS" \
    --checksums "$CHECKSUMS_STATUS" \
    --validation "$VALIDATION_STATUS" \
    --validation-mode "$VALIDATE_MODE" \
    --compare-status "$COMPARE_STATUS" \
    --compare-md "${REPORTS_DIR}/log_metrics_compare.md" \
    --compare-html "${REPORTS_DIR}/log_metrics_compare.html" \
    --manifest "$manifest_path" \
    --bundle "${REPORTS_DIR}/log_metrics_bundle.tar.gz" \
    --checksums-path "$checksum_path" \
    --portal "${REPORTS_DIR}/portal.html" \
    --index "${REPORTS_DIR}/index.md" \
    --status-json "$STATUS_JSON_PATH" \
    --include-manifest-from-status \
    --status-overall "$OVERALL_STATUS" \
    --status-badge "$STATUS_BADGE_PATH" \
    --sitemap-status "$SITEMAP_STATUS" \
    --sitemap-json "$SITEMAP_JSON_PATH" \
    --sitemap-md "$SITEMAP_MD_PATH" \
    --sitemap-html "$SITEMAP_HTML_PATH" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.json"
fi

if [ "$WRITE_RUN_SUMMARY_MD" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary_md.py" \
    --reports "$REPORTS_DIR" \
    --run-summary "${REPORTS_DIR}/log_metrics_run_summary.json" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.md"
fi

if [ "$WRITE_RUN_SUMMARY_HTML" = true ]; then
  python3 "$SCRIPT_DIR/logs_metrics_run_summary_html.py" \
    --reports "$REPORTS_DIR" \
    --run-summary "${REPORTS_DIR}/log_metrics_run_summary.json" \
    --output "${REPORTS_DIR}/log_metrics_run_summary.html"
fi

if [ "$WRITE_CHECKSUMS" = true ]; then
  echo "[checksums] Regenerating checksums after final run summary"
  "$SCRIPT_DIR/logs_metrics_checksums.sh" --reports "$REPORTS_DIR" --suffix "$suffix" --output "$checksum_path"
fi

if [ "$WRITE_VERIFY_CHECKSUMS" = true ]; then
  echo "[verify-checksums] Verifying final checksums (post-run-summary)"
  (cd "$REPORTS_DIR" && sha256sum --check "$(basename "$checksum_path")")
fi

echo "Done. Reports available at:"
echo " - $csv_path"
echo " - ${base}.json"
echo " - $md_path"
echo " - $html_path"
