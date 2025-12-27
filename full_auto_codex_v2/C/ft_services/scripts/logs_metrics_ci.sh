#!/bin/bash
# CI-oriented runner: pipeline (export+verify+reports+index), optional compare, alert, history/trend, bundle, and JSONL.
set -euo pipefail

LOG_DIR=${LOG_METRICS_DIR:-tests/env/logs}
REPORTS_DIR=${REPORTS_DIR:-reports}
PATTERN="status"
TOPN=2
THRESHOLD=""
COMPARE_BASE=""
SUFFIX=""
PRUNE_KEEP=""
ANOMALY_THRESHOLD=""
ANOMALIES_STRICT=false
ANOMALIES_JSON=true
ANOMALIES_HTML=true
ANOMALIES_MD=true
NO_CHECKSUMS=false
NO_VERIFY_CHECKSUMS=false
NO_OVERVIEW=false
NO_OVERVIEW_HTML=false
NO_PORTAL=false
NO_TREND_HTML=false
NO_STATS_HTML=false
NO_SUMMARY_HTML=false
NO_INDEX_HTML=false
NO_MANIFEST=false
NO_MANIFEST_HASH=false
PROFILE="full"
NO_BUNDLE=false
NO_LATEST=false
NO_BADGE=false
NO_GUARD_CHECK=false
BADGE_GATE=""
BADGE_WARN=50
BADGE_DANGER=80
BADGE_LABEL="metrics"
NO_BADGE_HISTORY=false
BADGE_HISTORY_LAST=20
BADGE_OK_STREAK=0
BADGE_NO_REGRESSION=false
POST_VALIDATE=false
VALIDATE_MODE="full"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
    --dir=*) LOG_DIR=${1#*=}; shift ;;
    --dir) LOG_DIR=$2; shift 2 ;;
    --reports=*) REPORTS_DIR=${1#*=}; shift ;;
    --reports) REPORTS_DIR=$2; shift 2 ;;
    --pattern=*) PATTERN=${1#*=}; shift ;;
    --pattern) PATTERN=$2; shift 2 ;;
    --topn=*) TOPN=${1#*=}; shift ;;
    --topn) TOPN=$2; shift 2 ;;
    --threshold=*) THRESHOLD=${1#*=}; shift ;;
    --threshold) THRESHOLD=$2; shift 2 ;;
    --compare=*) COMPARE_BASE=${1#*=}; shift ;;
    --compare) COMPARE_BASE=$2; shift 2 ;;
    --suffix=*) SUFFIX=${1#*=}; shift ;;
    --suffix) SUFFIX=$2; shift 2 ;;
    --prune-keep=*) PRUNE_KEEP=${1#*=}; shift ;;
    --prune-keep) PRUNE_KEEP=$2; shift 2 ;;
    --anomaly-threshold=*) ANOMALY_THRESHOLD=${1#*=}; shift ;;
    --anomaly-threshold) ANOMALY_THRESHOLD=$2; shift 2 ;;
    --anomalies-strict) ANOMALIES_STRICT=true; shift ;;
    --no-anomalies) ANOMALIES_MD=false; shift ;;
    --no-anomalies-html) ANOMALIES_HTML=false; shift ;;
    --no-anomalies-json) ANOMALIES_JSON=false; shift ;;
    --no-checksums) NO_CHECKSUMS=true; shift ;;
    --no-verify-checksums) NO_VERIFY_CHECKSUMS=true; shift ;;
    --no-overview) NO_OVERVIEW=true; shift ;;
    --no-overview-html) NO_OVERVIEW_HTML=true; shift ;;
    --no-portal) NO_PORTAL=true; shift ;;
    --no-trend-html) NO_TREND_HTML=true; shift ;;
    --no-stats-html) NO_STATS_HTML=true; shift ;;
    --no-summary-html) NO_SUMMARY_HTML=true; shift ;;
    --no-index-html) NO_INDEX_HTML=true; shift ;;
    --no-manifest) NO_MANIFEST=true; shift ;;
    --no-manifest-hash) NO_MANIFEST_HASH=true; shift ;;
    --no-bundle) NO_BUNDLE=true; shift ;;
    --post-validate) POST_VALIDATE=true; shift ;;
    --validate-mode=*) VALIDATE_MODE=${1#*=}; shift ;;
    --validate-mode) VALIDATE_MODE=$2; shift 2 ;;
    --no-latest) NO_LATEST=true; shift ;;
    --no-badge) NO_BADGE=true; shift ;;
    --no-guard-check) NO_GUARD_CHECK=true; shift ;;
    --badge-gate=*) BADGE_GATE=${1#*=}; shift ;;
    --badge-gate) BADGE_GATE=$2; shift 2 ;;
    --badge-warn=*) BADGE_WARN=${1#*=}; shift ;;
    --badge-warn) BADGE_WARN=$2; shift 2 ;;
    --badge-danger=*) BADGE_DANGER=${1#*=}; shift ;;
    --badge-danger) BADGE_DANGER=$2; shift 2 ;;
    --badge-label=*) BADGE_LABEL=${1#*=}; shift ;;
    --badge-label) BADGE_LABEL=$2; shift 2 ;;
    --no-badge-history) NO_BADGE_HISTORY=true; shift ;;
    --badge-history-last=*) BADGE_HISTORY_LAST=${1#*=}; shift ;;
    --badge-history-last) BADGE_HISTORY_LAST=$2; shift 2 ;;
    --badge-ok-streak=*) BADGE_OK_STREAK=${1#*=}; shift ;;
    --badge-ok-streak) BADGE_OK_STREAK=$2; shift 2 ;;
    --badge-no-regression) BADGE_NO_REGRESSION=true; shift ;;
    --profile=*) PROFILE=${1#*=}; shift ;;
    --profile) PROFILE=$2; shift 2 ;;
    --help)
      cat <<EOF
Usage: $0 [--dir LOG_DIR] [--reports DIR] [--pattern NAME] [--topn N] [--threshold N] [--compare base.csv] [--suffix pattern_topN]
Runs logs_metrics_pipeline (verify+reports+index+history+trend/stats/anomalies), optionally compares to a base CSV, emits JSONL, then bundles the artifacts.
Anomalies options: --anomaly-threshold N, --anomalies-strict (exit >0 on anomalies), --no-anomalies[-(html|json)].
Checksums options: --no-checksums (skip generation), --no-verify-checksums (skip verification).
Overview options: --no-overview (skip overview md), --no-overview-html (skip overview HTML).
HTML options: --no-portal, --no-trend-html, --no-stats-html, --no-summary-html, --no-index-html.
Manifest options: --no-manifest, --no-manifest-hash (skip sha256 in manifest).
Bundle options: --no-bundle (ne pas générer l’archive tar.gz).
Latest options: --no-latest (ne pas générer log_metrics_latest.json/html/md).
Guard summary check: --no-guard-check (ne pas vérifier la cohérence CSV/JSON).
Badge options: --no-badge (ne pas générer le badge SVG log_metrics_badge.svg), --badge-gate warn|alert (échouer si l’état du badge atteint le seuil), --badge-warn/--badge-danger/--badge-label pour personnaliser le badge, --badge-ok-streak N (échouer si la streak OK courante est < N), --badge-no-regression (échouer si l’état se dégrade vs l’entrée précédente).
Badge history options: --no-badge-history (désactive l’historique badge csv/md/html), --badge-history-last N (nombre d’entrées affichées dans les vues md/html).
Profiles: --profile minimal|standard|full (presets for common CI footprints, default full).
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

if [ -z "$SUFFIX" ]; then
  pattern_label=$(printf "%s" "$PATTERN" | tr -cs '[:alnum:]_-' '_')
  top_label=${TOPN#-}
  SUFFIX="${pattern_label}_top${top_label}"
fi

# Apply profile presets (overrides individual flags if set)
case "$PROFILE" in
  minimal)
    NO_PORTAL=true
    NO_TREND_HTML=true
    NO_STATS_HTML=true
    NO_SUMMARY_HTML=true
    NO_INDEX_HTML=true
    NO_OVERVIEW_HTML=true
    NO_MANIFEST_HASH=true
    NO_BUNDLE=true
    NO_LATEST=true
    NO_BADGE=true
    ;;
  standard)
    NO_MANIFEST_HASH=true
    ;;
  full) ;;
  *)
    echo "Unknown profile: $PROFILE (expected minimal|standard|full)" >&2
    exit 1
    ;;
esac

if [[ "$LOG_DIR" != /* ]]; then
  LOG_DIR="$REPO_ROOT/$LOG_DIR"
fi
if [[ "$REPORTS_DIR" != /* ]]; then
  REPORTS_DIR="$REPO_ROOT/$REPORTS_DIR"
fi
if [[ -n "$COMPARE_BASE" && "$COMPARE_BASE" != /* ]]; then
  COMPARE_BASE="$REPO_ROOT/$COMPARE_BASE"
fi

echo "[ci] Running pipeline (pattern=${PATTERN}, topn=${TOPN}, threshold=${THRESHOLD:-none})"
pipeline_args=(--pattern "$PATTERN" --topn "$TOPN" --dir "$LOG_DIR" --reports "$REPORTS_DIR")
[ -n "$THRESHOLD" ] && pipeline_args+=(--threshold "$THRESHOLD")
[ -n "$PRUNE_KEEP" ] && pipeline_args+=(--prune-keep "$PRUNE_KEEP")
[ -n "$ANOMALY_THRESHOLD" ] && pipeline_args+=(--anomaly-threshold "$ANOMALY_THRESHOLD")
[ "$ANOMALIES_STRICT" = true ] && pipeline_args+=(--anomalies-strict)
[ "$ANOMALIES_MD" = false ] && pipeline_args+=(--no-anomalies)
[ "$ANOMALIES_HTML" = false ] && pipeline_args+=(--no-anomalies-html)
[ "$ANOMALIES_JSON" = false ] && pipeline_args+=(--no-anomalies-json)
[ "$NO_CHECKSUMS" = true ] && pipeline_args+=(--no-checksums)
[ "$NO_VERIFY_CHECKSUMS" = true ] && pipeline_args+=(--no-verify-checksums)
[ "$NO_OVERVIEW" = true ] && pipeline_args+=(--no-overview)
[ "$NO_OVERVIEW_HTML" = true ] && pipeline_args+=(--no-overview-html)
[ "$NO_PORTAL" = true ] && pipeline_args+=(--no-portal)
[ "$NO_TREND_HTML" = true ] && pipeline_args+=(--no-trend-html)
[ "$NO_STATS_HTML" = true ] && pipeline_args+=(--no-stats-html)
[ "$NO_SUMMARY_HTML" = true ] && pipeline_args+=(--no-summary-html)
[ "$NO_INDEX_HTML" = true ] && pipeline_args+=(--no-index-html)
[ "$NO_MANIFEST" = true ] && pipeline_args+=(--no-manifest)
[ "$NO_MANIFEST_HASH" = true ] && pipeline_args+=(--no-manifest-hash)
[ "$NO_BUNDLE" = true ] && pipeline_args+=(--no-bundle)
[ "$NO_LATEST" = true ] && pipeline_args+=(--no-latest)
[ "$NO_BADGE" = true ] && pipeline_args+=(--no-badge)
[ "$NO_BADGE" = false ] && pipeline_args+=(--badge-warn "$BADGE_WARN" --badge-danger "$BADGE_DANGER" --badge-label "$BADGE_LABEL")
[ -n "$BADGE_GATE" ] && pipeline_args+=(--badge-gate "$BADGE_GATE")
[ "$NO_BADGE_HISTORY" = true ] && pipeline_args+=(--no-badge-history)
[ "$NO_BADGE_HISTORY" = false ] && pipeline_args+=(--badge-history-last "$BADGE_HISTORY_LAST")
[ "$BADGE_OK_STREAK" -gt 0 ] && pipeline_args+=(--badge-ok-streak "$BADGE_OK_STREAK")
[ "$BADGE_NO_REGRESSION" = true ] && pipeline_args+=(--badge-no-regression)
[ "$POST_VALIDATE" = true ] && pipeline_args+=(--post-validate --validate-mode "$VALIDATE_MODE")
"$SCRIPT_DIR/logs_metrics_pipeline.sh" "${pipeline_args[@]}"

target_csv="${REPORTS_DIR}/log_metrics_snapshot.${SUFFIX}.csv"
if [ -n "$COMPARE_BASE" ]; then
  echo "[ci] Comparing ${COMPARE_BASE} -> ${target_csv}"
  python3 "$SCRIPT_DIR/logs_metrics_compare.py" --base "$COMPARE_BASE" --target "$target_csv" --output "${REPORTS_DIR}/log_metrics_compare.md"
  python3 "$SCRIPT_DIR/logs_metrics_compare_html.py" --base "$COMPARE_BASE" --target "$target_csv" --output "${REPORTS_DIR}/log_metrics_compare.html"
fi

if [ "$POST_VALIDATE" = true ]; then
  echo "[ci] Running validation (mode=${VALIDATE_MODE})"
  python3 "$SCRIPT_DIR/logs_metrics_validate.py" --reports "$REPORTS_DIR" --suffix "$SUFFIX" --mode "$VALIDATE_MODE"
fi

echo "[ci] Exporting JSONL"
python3 "$SCRIPT_DIR/logs_metrics_snapshot_to_jsonl.py" --input "$target_csv" --output "${target_csv%.csv}.jsonl"

echo "[ci] Bundling artifacts"
"$SCRIPT_DIR/logs_metrics_publish.sh" --reports "$REPORTS_DIR" --suffix "$SUFFIX" --output "${REPORTS_DIR}/log_metrics_bundle.tar.gz"

if [ "$NO_GUARD_CHECK" = false ]; then
  if [ -f "${REPORTS_DIR}/log_metrics_guard_summary.csv" ] && [ -f "${REPORTS_DIR}/log_metrics_guard_summary.json" ]; then
    echo "[ci] Checking guard_summary CSV vs JSON"
    python3 ./scripts/logs_metrics_guard_summary_check.py --csv "${REPORTS_DIR}/log_metrics_guard_summary.csv" --json "${REPORTS_DIR}/log_metrics_guard_summary.json"
  else
    echo "[ci] Skip guard_summary check (files missing)"
  fi
fi

echo "[ci] Done."
