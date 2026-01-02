NAME := ft_nmap
CC := gcc
CFLAGS := -Wall -Wextra -Werror -MMD -MP
INCLUDES := -Iinclude

SRC := src/main.c \
	src/parse.c \
	src/output.c \
	src/scan.c \
	src/utils.c

OBJ := $(SRC:.c=.o)
DEPS := $(OBJ:.o=.d)

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) $(INCLUDES) $^ -o $@

test: $(NAME)
	bash tests_realisation/basic_local_scan.sh
	bash tests_realisation/stdin_ports_scan.sh
	bash tests_realisation/exclude_ports_scan.sh
	bash tests_realisation/top_ports_scan.sh
	bash tests_realisation/stop_on_open_scan.sh
	bash tests_realisation/stop_after_n_open.sh
	bash tests_realisation/ndjson_export.sh
	bash tests_realisation/stats_json.sh
	bash tests_realisation/random_seed.sh
	bash tests_realisation/progress.sh
	bash tests_realisation/wait_delay.sh
	bash tests_realisation/deadline_scan.sh
	bash tests_realisation/html_export.sh
	bash tests_realisation/xml_export.sh
	bash tests_realisation/export_filter.sh
	bash tests_realisation/markdown_export.sh
	bash tests_realisation/stdout_json.sh
	bash tests_realisation/json_summary.sh
	bash tests_realisation/resolved_ip.sh
	bash tests_realisation/version.sh
	bash tests_realisation/dry_run.sh
	bash tests_realisation/dry_run_exports.sh
	bash tests_realisation/open_list.sh
	bash tests_realisation/service_names.sh
	bash tests_realisation/targets_file.sh
	bash tests_realisation/scan_udp.sh
	bash tests_realisation/port_limit.sh

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

-include $(DEPS)

clean:
	rm -f $(OBJ) $(DEPS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re test
