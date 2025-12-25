#!/bin/bash
set -euo pipefail

LOG_DIR=${LOG_METRICS_DIR:-tests/env/logs}
FORMAT=csv
PATTERN=
TOPN=0

show_help() {
  cat <<EOF
Usage: $0 [--dir PATH] [--topn N] [--pattern NAME] [--format csv|json]
Positional compatibility is kept: log_dir [top_n [pattern]].
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --help) show_help; exit 0 ;;
    --dir=*) LOG_DIR=${1#*=}; shift ;;
    --dir) LOG_DIR=$2; shift 2 ;;
    --topn=*) TOPN=${1#*=}; shift ;;
    --topn) TOPN=$2; shift 2 ;;
    --pattern=*) PATTERN=${1#*=}; shift ;;
    --pattern) PATTERN=$2; shift 2 ;;
    --format=*) FORMAT=${1#*=}; shift ;;
    --format) FORMAT=$2; shift 2 ;;
    --) shift; break ;;
    -*)
      echo "Unknown option $1" >&2
      show_help
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

# Positional fallback for backward compatibility
if [ $# -gt 0 ]; then
  LOG_DIR=$1
  shift
fi
if [ $# -gt 0 ]; then
  TOPN=$1
  shift
fi
if [ $# -gt 0 ]; then
  PATTERN=$1
  shift
fi

if [ "$FORMAT" != "csv" ] && [ "$FORMAT" != "json" ]; then
  echo "Invalid format: $FORMAT (expected csv or json)" >&2
  exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
  echo "Log directory $LOG_DIR not found" >&2
  exit 1
fi

find_pattern=(-name '*.log')
if [ -n "$PATTERN" ]; then
  find_pattern=(-name "*${PATTERN}*.log")
fi

mapfile -d '' files < <(find "$LOG_DIR" -type f "${find_pattern[@]}" -print0 2>/dev/null)
if [ ${#files[@]} -eq 0 ]; then
  echo "No log files found in $LOG_DIR" >&2
  exit 1
fi

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
data_rows=()
total_status=0
total_connections=0
total_overloaded=0
for file in "${files[@]}"; do
  status=$(grep -c "status check" "$file" 2>/dev/null || true)
  connections=$(grep -c "connections:" "$file" 2>/dev/null || true)
  overloaded=$(grep -c "overloaded" "$file" 2>/dev/null || true)
  ratio=$(awk -v o=$overloaded -v s=$status 'BEGIN { printf "%.2f", (s > 0 ? (o/s)*100 : 0) }')
  data_rows+=("$file|$status|$connections|$overloaded|$ratio")
  total_status=$((total_status + status))
  total_connections=$((total_connections + connections))
  total_overloaded=$((total_overloaded + overloaded))
done

total_ratio=$(awk -v o=$total_overloaded -v s=$total_status 'BEGIN { printf "%.2f", (s > 0 ? (o/s)*100 : 0) }')

results=("${data_rows[@]}")
if [ "$TOPN" -ne 0 ]; then
  sort_flag="-r"
  [ "$TOPN" -lt 0 ] && sort_flag=""
  mapfile -t results < <(printf "%s\n" "${data_rows[@]}" | sort -t'|' -k4 $sort_flag)
  TOPN=${TOPN#-}
  results=("${results[@]:0:$TOPN}")
fi
results+=("Totals|$total_status|$total_connections|$total_overloaded|$total_ratio")

if [ "$FORMAT" = "csv" ]; then
  echo "timestamp,log_file,status_checks,connections,overloaded,overloaded_ratio"
  for line in "${results[@]}"; do
    IFS='|' read -r file status connections overloaded ratio <<< "$line"
    echo "${timestamp},${file},${status},${connections},${overloaded},${ratio}"
  done
else
  echo "["
  first=true
  for line in "${results[@]}"; do
    file=${line%%|*}
    rest=${line#*|}
    IFS='|' read -r status connections overloaded ratio <<< "$rest"
    [ "$first" = true ] && first=false || echo ","
    printf '  {"timestamp":"%s","log_file":"%s","status_checks":%s,"connections":%s,"overloaded":%s,"overloaded_ratio":%s}' \
      "$timestamp" "$file" "$status" "$connections" "$overloaded" "$ratio"
  done
  echo
  echo "]"
fi
