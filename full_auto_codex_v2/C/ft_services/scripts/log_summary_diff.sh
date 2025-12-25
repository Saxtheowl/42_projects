#!/bin/sh

cfg_a=${1:-tests/env/ft_services_status.conf}
cfg_b=${2:-tests/env/ft_services.conf}

log_path() {
  cfg=$1
  if [ ! -f "$cfg" ]; then
    echo "Config $cfg missing" >&2
    exit 1
  fi
  awk -F= '/^log_path/ {gsub(/^[\t ]+|[\t ]+$/,"", $2); print $2; exit}' "$cfg"
}

counts() {
  log=$1
  status=$(grep -c "status check" "$log" 2>/dev/null || true)
  count=$(grep -c "connections:" "$log" 2>/dev/null || true)
  overloaded=$(grep -c "overloaded" "$log" 2>/dev/null || true)
  echo "$status $count $overloaded"
}

diff_value() {
  expr=$(( $2 - $1 ))
  echo "$expr"
}

path_a=$(log_path "$cfg_a")
path_b=$(log_path "$cfg_b")
set -- $(counts "$path_a")
status_a=$1
count_a=$2
over_a=$3
set -- $(counts "$path_b")
status_b=$1
count_b=$2
over_b=$3

echo "Comparing logs for $cfg_a vs $cfg_b"
echo "$cfg_a -> status checks=$status_a count replies=$count_a overload notices=$over_a"
echo "$cfg_b -> status checks=$status_b count replies=$count_b overload notices=$over_b"
echo "Differences (cfg_b - cfg_a):"
echo " status checks: $(diff_value $status_a $status_b)"
echo " count replies: $(diff_value $count_a $count_b)"
echo " overload notices: $(diff_value $over_a $over_b)"
