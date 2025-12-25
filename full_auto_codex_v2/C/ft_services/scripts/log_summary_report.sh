#!/bin/sh
CONFIGS=${@:-"tests/env/ft_services_status.conf tests/env/ft_services.conf"}
set -- $CONFIGS
first=$1
shift
if [ -z "$first" ] || [ $# -eq 0 ]; then
  echo "Usage: $0 config1 config2 [config3 ...]"
  echo "At least two configs required to compare logs."
  exit 1
fi

echo "Running log_summary_multi on: $CONFIGS"
./scripts/log_summary_multi.sh $CONFIGS || exit 1

echo "\nComparing first config ($first) against each remaining one using log_summary_diff"
for cfg in "$@"; do
  ./scripts/log_summary_diff.sh "$first" "$cfg" || exit 1
done
