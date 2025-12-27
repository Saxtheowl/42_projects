CC ?= gcc
CFLAGS ?= -Wall -Wextra -Werror -Iinclude
BIN = ft_services
SRCS = src/main.c src/config.c src/args.c src/log.c
OBJS = $(SRCS:.c=.o)
LOG_DIR ?= tests/env/logs
THRESHOLD ?= 60
KEEP ?= 5
FAIL_ON_OVERALL ?=
SITEMAP_OPTIONAL ?= compare_md,compare_html,checksums_guard
SITEMAP_STRICT ?=

all: $(BIN)

$(BIN): $(SRCS)
	$(CC) $(CFLAGS) $(SRCS) -o $(BIN)

clean:
	rm -f $(BIN) *.o

.PHONY: all clean metrics metrics-ci metrics-prune metrics-validate metrics-checksums metrics-verify-checksums metrics-badge metrics-quick-check
.PHONY: metrics-guard-summary-check metrics-guard-latest-check
.PHONY: metrics-smoke
.PHONY: metrics-snapshot-check
.PHONY: metrics-run-summary metrics-sitemap metrics-sitemap-html metrics-sitemap-json metrics-sitemap-all metrics-sitemap-verify
.PHONY: metrics-status

metrics:
	./scripts/logs_metrics_pipeline.sh --dir $(LOG_DIR) --threshold $(THRESHOLD) --prune-keep $(KEEP)

metrics-latest:
	python3 ./scripts/logs_metrics_latest.py --reports reports --suffix status_top2 --output reports/log_metrics_latest.json

metrics-badge:
	python3 ./scripts/logs_metrics_badge.py --reports reports --suffix status_top2 --output reports/log_metrics_badge.svg

metrics-badge-history:
	python3 ./scripts/logs_metrics_badge_history.py --latest reports/log_metrics_latest.json --output reports/log_metrics_badge_history.csv
	python3 ./scripts/logs_metrics_badge_history_md.py --history reports/log_metrics_badge_history.csv --output reports/log_metrics_badge_history.md
	python3 ./scripts/logs_metrics_badge_history_html.py --history reports/log_metrics_badge_history.csv --output reports/log_metrics_badge_history.html

metrics-ci:
	./scripts/logs_metrics_ci.sh --dir $(LOG_DIR) --threshold $(THRESHOLD) --prune-keep $(KEEP)

metrics-ci-minimal:
	./scripts/logs_metrics_ci.sh --dir $(LOG_DIR) --threshold $(THRESHOLD) --prune-keep $(KEEP) --profile minimal

metrics-ci-standard:
	./scripts/logs_metrics_ci.sh --dir $(LOG_DIR) --threshold $(THRESHOLD) --prune-keep $(KEEP) --profile standard

metrics-ci-full:
	./scripts/logs_metrics_ci.sh --dir $(LOG_DIR) --threshold $(THRESHOLD) --prune-keep $(KEEP) --profile full

metrics-prune:
	./scripts/logs_metrics_prune_reports.sh --reports reports --suffix status_top2 --keep $(KEEP)

metrics-validate:
	./scripts/logs_metrics_validate.py --reports reports --suffix status_top2

metrics-validate-standard:
	./scripts/logs_metrics_validate.py --reports reports --suffix status_top2 --mode standard

metrics-validate-minimal:
	./scripts/logs_metrics_validate.py --reports reports --suffix status_top2 --mode minimal

metrics-guard-summary-check:
	python3 ./scripts/logs_metrics_guard_summary_check.py --csv reports/log_metrics_guard_summary.csv --json reports/log_metrics_guard_summary.json

metrics-guard-latest-check:
	python3 ./scripts/logs_metrics_guard_latest_check.py --latest reports/log_metrics_latest.json --guard-summary reports/log_metrics_guard_summary.json

metrics-checksums:
	bash ./scripts/logs_metrics_checksums.sh --reports reports --suffix status_top2 --output reports/log_metrics_checksums.txt

metrics-verify-checksums:
	python3 ./scripts/logs_metrics_verify_checksums.py --reports reports --suffix status_top2

metrics-quick-check:
	bash ./scripts/metrics_quick_check.sh --reports reports --suffix status_top2

metrics-snapshot-check:
	python3 ./scripts/logs_metrics_snapshot_check.py --reports reports --suffix status_top2

metrics-smoke:
	bash ./scripts/metrics_smoke.sh --dir $(LOG_DIR) --reports reports --threshold $(THRESHOLD) --prune-keep $(KEEP) --guard-delta-last 10 --sitemap-optional $(SITEMAP_OPTIONAL) $(if $(SITEMAP_STRICT),--sitemap-strict,) $(if $(FAIL_ON_OVERALL),--fail-on-overall $(FAIL_ON_OVERALL),)

metrics-run-summary:
	python3 ./scripts/logs_metrics_run_summary.py --reports reports --suffix status_top2 --latest reports/log_metrics_latest.json --guard-check ok --checksums ok --validation ok --validation-mode full --output reports/log_metrics_run_summary.json
	python3 ./scripts/logs_metrics_run_summary_md.py --reports reports --run-summary reports/log_metrics_run_summary.json --output reports/log_metrics_run_summary.md
	python3 ./scripts/logs_metrics_run_summary_html.py --reports reports --run-summary reports/log_metrics_run_summary.json --output reports/log_metrics_run_summary.html

metrics-sitemap:
	python3 ./scripts/logs_metrics_sitemap_md.py --reports reports --manifest reports/log_metrics_manifest.json --output reports/log_metrics_sitemap.md

metrics-sitemap-html:
	python3 ./scripts/logs_metrics_sitemap_html.py --reports reports --manifest reports/log_metrics_manifest.json --output reports/log_metrics_sitemap.html

metrics-sitemap-json:
	python3 ./scripts/logs_metrics_sitemap_json.py --reports reports --manifest reports/log_metrics_manifest.json --output reports/log_metrics_sitemap.json

metrics-sitemap-all: metrics-sitemap metrics-sitemap-html metrics-sitemap-json

metrics-sitemap-verify:
	python3 ./scripts/logs_metrics_sitemap_verify.py --reports reports --sitemap reports/log_metrics_sitemap.json $(if $(SITEMAP_OPTIONAL),--optional $(SITEMAP_OPTIONAL),) $(if $(SITEMAP_STRICT),--strict-summary,)

metrics-status:
	python3 ./scripts/logs_metrics_status.py --reports reports --format text
	python3 ./scripts/logs_metrics_status_badge.py --status-json reports/log_metrics_status.json --output reports/log_metrics_status_badge.svg
