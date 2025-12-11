#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
VENV="${PROJECT_ROOT}/.venv/bin/python"
DATASET="${PROJECT_ROOT}/data/data.csv"
HISTORY="${PROJECT_ROOT}/data/history.json"
PLOTS_DIR="${PROJECT_ROOT}/plots"
RMSE_PLOT_SCRIPT="${PROJECT_ROOT}/../ft_helpme/scripts/reports/rmse_plot.py"

if [ ! -x "${VENV}" ]; then
	printf 'Python venv not found. Create it with `python3 -m venv .venv`\n' >&2
	exit 1
fi

"${VENV}" "${PROJECT_ROOT}/src/train.py" "${DATASET}" --history "${HISTORY}" "$@"

mkdir -p "${PLOTS_DIR}"
if [ -f "${RMSE_PLOT_SCRIPT}" ]; then
	python3 "${RMSE_PLOT_SCRIPT}" "${HISTORY}" --png "${PLOTS_DIR}/latest_rmse.png" > "${PLOTS_DIR}/latest_rmse.txt" 2>&1 || true
fi
