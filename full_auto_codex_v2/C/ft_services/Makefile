CC ?= gcc
CFLAGS ?= -Wall -Wextra -Werror -Iinclude
BIN = ft_services
SRCS = src/main.c src/config.c src/args.c src/log.c
OBJS = $(SRCS:.c=.o)
LOG_DIR ?= tests/env/logs
THRESHOLD ?= 60
KEEP ?= 5

all: $(BIN)

$(BIN): $(SRCS)
	$(CC) $(CFLAGS) $(SRCS) -o $(BIN)

clean:
	rm -f $(BIN) *.o

.PHONY: all clean metrics metrics-ci metrics-prune metrics-validate metrics-checksums metrics-verify-checksums metrics-badge

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

metrics-checksums:
	bash ./scripts/logs_metrics_checksums.sh --reports reports --suffix status_top2 --output reports/log_metrics_checksums.txt

metrics-verify-checksums:
	python3 ./scripts/logs_metrics_verify_checksums.py --reports reports --suffix status_top2
