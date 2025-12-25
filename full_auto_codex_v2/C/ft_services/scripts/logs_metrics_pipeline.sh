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
WRITE_BADGE=true
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

write_latest_json() {
  python3 ./scripts/logs_metrics_latest.py \
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
    --badge-ok-streak=*) BADGE_OK_STREAK=${1#*=}; shift ;;
    --badge-ok-streak) BADGE_OK_STREAK=$2; shift 2 ;;
    --badge-no-regression) BADGE_NO_REGRESSION=true; shift ;;
    --no-guard-summary) WRITE_GUARD_SUMMARY=false; shift ;;
    --help)
      cat <<EOF
Usage: $0 [--pattern NAME] [--topn N] [--dir LOG_DIR] [--reports REPORTS_DIR] [--threshold N] [--no-index] [--no-jsonl] [--no-index-html] [--no-summary] [--no-summary-html] [--no-stats] [--no-portal] [--no-trend-html] [--no-anomalies] [--anomaly-threshold N] [--history PATH] [--prune-keep N] [--compare base.csv] [--no-manifest] [--no-manifest-hash] [--no-checksums] [--no-verify-checksums] [--no-overview] [--no-overview-html] [--no-bundle] [--no-latest] [--no-latest-html] [--no-latest-md] [--no-badge] [--badge-warn N] [--badge-danger N] [--badge-label TEXT] [--badge-gate warn|alert] [--no-badge-history] [--badge-history-last N] [--guard-delta-last N] [--badge-ok-streak N] [--badge-no-regression] [--no-guard-summary]
Runs verify_snapshot (CSV+JSON), then renders Markdown and HTML reports from the CSV, optionally enforces an overload ratio threshold, writes summary (md+html)/history/trend (md+html)/stats (md+html)/anomalies (md+html+json), optional compare (md+html), index (md/html), portal, overview (md+html), latest summary (json+html+md), badge SVG (customizable thresholds/label), optional badge gate (warn/alert), OK streak guard, regression guard, badge history CSV/md/html, manifest JSON (with sha256 unless disabled), bundle tar.gz, checksums file, and prunes old snapshots.
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

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
./scripts/verify_snapshot.sh --format both --pattern "$PATTERN" --topn "$TOPN" --dir "$LOG_DIR" --reports "$REPORTS_DIR"

csv_path="${base}.csv"
html_path="${base}.html"
md_path="${base}.md"

if [ ! -f "$csv_path" ]; then
  echo "CSV snapshot not found at $csv_path" >&2
  exit 1
fi

echo "[2/3] Rendering Markdown report -> ${md_path}"
./scripts/logs_metrics_report.sh --input "$csv_path" --output "$md_path"

echo "[3/3] Rendering HTML report -> ${html_path}"
python3 ./scripts/logs_metrics_report_html.py --input "$csv_path" --output "$html_path"

if [ -n "$ALERT_THRESHOLD" ]; then
  echo "[alert] Checking overloaded_ratio <= ${ALERT_THRESHOLD}%"
  python3 ./scripts/logs_metrics_alerts.py --input "$csv_path" --threshold "$ALERT_THRESHOLD"
fi

if [ "$WRITE_JSONL" = true ]; then
  echo "[jsonl] Exporting JSONL"
  python3 ./scripts/logs_metrics_snapshot_to_jsonl.py --input "$csv_path" --output "${base}.jsonl"
fi

if [ "$WRITE_SUMMARY" = true ]; then
  echo "[summary] Writing summary report"
  python3 ./scripts/logs_metrics_summary.py --input "$csv_path" --output "${base}.summary.md"
  if [ "$WRITE_SUMMARY_HTML" = true ]; then
    echo "[summary-html] Writing summary HTML"
    python3 ./scripts/logs_metrics_summary_html.py --input "$csv_path" --output "${base}.summary.html"
  fi
fi

echo "[history] Appending snapshot summary"
python3 ./scripts/logs_metrics_history.py --input "$csv_path" --pattern "$PATTERN" --topn "$TOPN" --history "$HISTORY_PATH"

if [ -f "$HISTORY_PATH" ]; then
  echo "[trend] Rendering trend report"
  python3 ./scripts/logs_metrics_trend.py --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_trend.md"
  if [ "$WRITE_TREND_HTML" = true ]; then
    echo "[trend-html] Rendering trend HTML"
    python3 ./scripts/logs_metrics_trend_html.py --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_trend.html"
  fi
  if [ "$WRITE_STATS" = true ]; then
    echo "[stats] Computing history stats"
    python3 ./scripts/logs_metrics_stats.py --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_stats.md"
    if [ "$WRITE_STATS_HTML" = true ]; then
      echo "[stats-html] Rendering stats HTML"
      python3 ./scripts/logs_metrics_stats_html.py --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_stats.html"
    fi
  fi
  if [ "$WRITE_ANOMALIES" = true ]; then
    echo "[anomalies] Computing anomalies"
    python3 ./scripts/logs_metrics_anomalies.py --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_anomalies.md" --json-output "${REPORTS_DIR}/log_metrics_anomalies.json" --threshold "$ANOMALY_THRESHOLD" $( [ "$ANOMALIES_STRICT" = true ] && echo "--strict" )
    if [ "$WRITE_ANOMALIES_HTML" = true ]; then
      echo "[anomalies-html] Rendering anomalies HTML"
      python3 ./scripts/logs_metrics_anomalies_html.py --history "$HISTORY_PATH" --output "${REPORTS_DIR}/log_metrics_anomalies.html" --threshold "$ANOMALY_THRESHOLD"
    fi
    if [ "$WRITE_ANOMALIES_JSON" != true ]; then
      rm -f "${REPORTS_DIR}/log_metrics_anomalies.json"
    fi
  fi
fi

if [ "$WRITE_OVERVIEW" = true ]; then
  echo "[overview] Writing overview"
  python3 ./scripts/logs_metrics_overview.py --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_overview.md"
fi

if [ "$WRITE_OVERVIEW_HTML" = true ]; then
  echo "[overview-html] Writing overview HTML"
  python3 ./scripts/logs_metrics_overview_html.py --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_overview.html"
fi

if [ "$WRITE_LATEST" = true ]; then
  echo "[latest] Writing latest JSON summary"
  write_latest_json
fi

if [ "$WRITE_BADGE" = true ]; then
  echo "[badge] Writing badge SVG"
  python3 ./scripts/logs_metrics_badge.py --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_badge.svg" --warn-overloaded-ratio "$BADGE_WARN" --danger-overloaded-ratio "$BADGE_DANGER" --label "$BADGE_LABEL"
fi

if [ "$WRITE_BADGE_HISTORY" = true ]; then
  echo "[badge-history] Appending badge history"
  python3 ./scripts/logs_metrics_badge_history.py --latest "${REPORTS_DIR}/log_metrics_latest.json" --output "${REPORTS_DIR}/log_metrics_badge_history.csv"
  python3 ./scripts/logs_metrics_badge_history_md.py --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_badge_history.md" --last "$BADGE_HISTORY_LAST"
  python3 ./scripts/logs_metrics_badge_history_html.py --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_badge_history.html" --last "$BADGE_HISTORY_LAST"
  if [ "$WRITE_GUARD_SUMMARY" = true ]; then
    echo "[guard-summary] Writing guard summary"
    python3 ./scripts/logs_metrics_guard_summary.py --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_guard_summary.md" --last "$BADGE_HISTORY_LAST" --delta-last "$GUARD_DELTA_LAST"
    python3 ./scripts/logs_metrics_guard_summary_html.py --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_guard_summary.html" --last "$BADGE_HISTORY_LAST" --delta-last "$GUARD_DELTA_LAST"
    python3 ./scripts/logs_metrics_guard_summary_json.py --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_guard_summary.json" --last "$BADGE_HISTORY_LAST" --delta-last "$GUARD_DELTA_LAST"
    python3 ./scripts/logs_metrics_guard_summary_csv.py --history "${REPORTS_DIR}/log_metrics_badge_history.csv" --output "${REPORTS_DIR}/log_metrics_guard_summary.csv" --last "$BADGE_HISTORY_LAST" --delta-last "$GUARD_DELTA_LAST"
  fi
fi

if [ "$WRITE_LATEST" = true ] && [ "$WRITE_BADGE_HISTORY" = true ]; then
  echo "[latest] Refreshing latest JSON summary with badge history"
  write_latest_json
fi

if [ "$WRITE_LATEST_HTML" = true ]; then
  echo "[latest-html] Writing latest HTML summary"
  python3 ./scripts/logs_metrics_latest_html.py --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_latest.html" --badge-warn "$BADGE_WARN" --badge-danger "$BADGE_DANGER" --badge-label "$BADGE_LABEL"
fi

if [ "$WRITE_LATEST_MD" = true ]; then
  echo "[latest-md] Writing latest Markdown summary"
  python3 ./scripts/logs_metrics_latest_md.py --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_latest.md" --badge-warn "$BADGE_WARN" --badge-danger "$BADGE_DANGER" --badge-label "$BADGE_LABEL"
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
  python3 ./scripts/logs_metrics_index.py --reports "$REPORTS_DIR" --suffix "$suffix"
  if [ "$WRITE_INDEX_HTML" = true ]; then
    python3 ./scripts/logs_metrics_index_html.py --reports "$REPORTS_DIR" --suffix "$suffix"
  fi
fi

if [ "$WRITE_PORTAL" = true ]; then
  echo "[portal] Rendering portal"
  python3 ./scripts/logs_metrics_portal.py --reports "$REPORTS_DIR" --suffix "$suffix"
fi

checksum_path="${REPORTS_DIR}/log_metrics_checksums.txt"
if [ "$WRITE_CHECKSUMS" = true ]; then
  # Pre-create the checksums file so the manifest can reference it with exists=true
  mkdir -p "$REPORTS_DIR"
  : > "$checksum_path"
fi

if [ "$WRITE_MANIFEST" = true ] && [ "$WRITE_BUNDLE" != true ]; then
  echo "[manifest] Writing manifest JSON"
  manifest_args=(--reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_manifest.json")
  if [ "$MANIFEST_HASH" = false ]; then
    manifest_args+=(--no-sha256)
  fi
  python3 ./scripts/logs_metrics_manifest.py "${manifest_args[@]}"
fi

if [ "$WRITE_BUNDLE" = true ]; then
  echo "[bundle] Building tar.gz bundle"
  ./scripts/logs_metrics_publish.sh --reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_bundle.tar.gz"
  if [ "$WRITE_MANIFEST" = true ]; then
    echo "[manifest] Refreshing manifest after bundle"
    manifest_args=(--reports "$REPORTS_DIR" --suffix "$suffix" --output "${REPORTS_DIR}/log_metrics_manifest.json")
    if [ "$MANIFEST_HASH" = false ]; then
      manifest_args+=(--no-sha256)
    fi
    python3 ./scripts/logs_metrics_manifest.py "${manifest_args[@]}"
  fi
fi

if [ "$WRITE_CHECKSUMS" = true ]; then
  echo "[checksums] Writing sha256 checksums"
  bash ./scripts/logs_metrics_checksums.sh --reports "$REPORTS_DIR" --suffix "$suffix" --output "$checksum_path"
fi

if [ "$WRITE_VERIFY_CHECKSUMS" = true ] && [ "$WRITE_CHECKSUMS" = true ]; then
  echo "[verify-checksums] Verifying checksums"
  python3 ./scripts/logs_metrics_verify_checksums.py --reports "$REPORTS_DIR" --suffix "$suffix" --checksums "$checksum_path" --manifest "${REPORTS_DIR}/log_metrics_manifest.json"
fi

if [ -n "$COMPARE_PATH" ]; then
  if [ ! -f "$COMPARE_PATH" ]; then
    echo "[compare] Base file $COMPARE_PATH not found" >&2
    exit 1
  fi
  echo "[compare] Writing diff vs $COMPARE_PATH"
  python3 ./scripts/logs_metrics_compare.py --base "$COMPARE_PATH" --target "$csv_path" --output "${REPORTS_DIR}/log_metrics_compare.md"
  python3 ./scripts/logs_metrics_compare_html.py --base "$COMPARE_PATH" --target "$csv_path" --output "${REPORTS_DIR}/log_metrics_compare.html"
fi

if [ -n "$PRUNE_KEEP" ]; then
  echo "[prune] Keeping latest ${PRUNE_KEEP} snapshots per extension"
  ./scripts/logs_metrics_prune_reports.sh --reports "$REPORTS_DIR" --suffix "$suffix" --keep "$PRUNE_KEEP"
fi

echo "Done. Reports available at:"
echo " - $csv_path"
echo " - ${base}.json"
echo " - $md_path"
echo " - $html_path"
