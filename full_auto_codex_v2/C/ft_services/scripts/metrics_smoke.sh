#!/bin/bash
# Full smoke: pipeline + quick-check with optional gates on overall/badge/missing.
# Usage: metrics_smoke.sh --dir tests/env/logs --reports reports --threshold 60 --prune-keep 5 --fail-on-overall alert
set -euo pipefail

DIR=${DIR:-tests/env/logs}
REPORTS=${REPORTS:-reports}
THRESHOLD=${THRESHOLD:-60}
KEEP=${KEEP:-5}
SITEMAP_OPTIONAL=${SITEMAP_OPTIONAL:-compare_md,compare_html,checksums_guard}
SITEMAP_STRICT=0
FAIL_ON_BADGE=""
FAIL_ON_OVERALL=""
FAIL_ON_MISSING=0
GUARD_DELTA_LAST=10

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
    --dir=*) DIR=${1#*=}; shift ;;
    --dir) DIR=$2; shift 2 ;;
    --reports=*) REPORTS=${1#*=}; shift ;;
    --reports) REPORTS=$2; shift 2 ;;
    --threshold=*) THRESHOLD=${1#*=}; shift ;;
    --threshold) THRESHOLD=$2; shift 2 ;;
    --prune-keep=*) KEEP=${1#*=}; shift ;;
    --prune-keep) KEEP=$2; shift 2 ;;
    --sitemap-optional=*) SITEMAP_OPTIONAL=${1#*=}; shift ;;
    --sitemap-strict) SITEMAP_STRICT=1; shift ;;
    --fail-on-badge=*) FAIL_ON_BADGE=${1#*=}; shift ;;
    --fail-on-badge) FAIL_ON_BADGE=$2; shift 2 ;;
    --fail-on-overall=*) FAIL_ON_OVERALL=${1#*=}; shift ;;
    --fail-on-overall) FAIL_ON_OVERALL=$2; shift 2 ;;
    --fail-on-missing) FAIL_ON_MISSING=1; shift ;;
    --guard-delta-last=*) GUARD_DELTA_LAST=${1#*=}; shift ;;
    --guard-delta-last) GUARD_DELTA_LAST=$2; shift 2 ;;
    --help)
      cat <<EOF
Usage: $0 [--dir DIR] [--reports DIR] [--threshold N] [--prune-keep N]
            [--sitemap-optional list] [--sitemap-strict]
            [--fail-on-badge warn|alert] [--fail-on-overall warn|alert] [--fail-on-missing]
Runs the full pipeline then metrics_quick_check with the same gates.
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

if [[ "$REPORTS" != /* ]]; then
  REPORTS="$REPO_ROOT/$REPORTS"
fi

echo "[smoke] Running pipeline"
pipeline_args=(
  --dir "$DIR"
  --reports "$REPORTS"
  --threshold "$THRESHOLD"
  --prune-keep "$KEEP"
  --sitemap-optional "$SITEMAP_OPTIONAL"
)
[ "$SITEMAP_STRICT" = "1" ] && pipeline_args+=("--sitemap-strict")
[ -n "$FAIL_ON_OVERALL" ] && pipeline_args+=("--fail-on-overall" "$FAIL_ON_OVERALL")
"$SCRIPT_DIR/logs_metrics_pipeline.sh" "${pipeline_args[@]}"

echo "[smoke] Running quick-check"
quick_args=("--reports" "$REPORTS" "--sitemap-optional" "$SITEMAP_OPTIONAL")
[ "$SITEMAP_STRICT" = "1" ] && quick_args+=("--sitemap-strict")
[ -n "$FAIL_ON_BADGE" ] && quick_args+=("--fail-on-badge" "$FAIL_ON_BADGE")
[ "$FAIL_ON_MISSING" = "1" ] && quick_args+=("--fail-on-missing")
[ -n "$FAIL_ON_OVERALL" ] && quick_args+=("--fail-on-overall" "$FAIL_ON_OVERALL")

bash "$SCRIPT_DIR/metrics_quick_check.sh" "${quick_args[@]}"

echo "[smoke] Done."
