#include "ft_ping.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>

static void	test_count_ttl_timeout_deadline_payload_pattern(void)
{
	char *argv[] = {"ft_ping", "-c", "5", "-t", "42", "-Q", "184", "-S", "127.0.0.1", "-i", "0.5", "-W", "1.5", "-w", "3.2", "-s", "64", "-p", "0a0b0c0d", "-q", "-O", "example.com", NULL};
	t_options opts;
	int ret = ft_parse_options(22, argv, &opts);
	assert(ret == 0);
	assert(opts.count == 5);
	assert(opts.ttl == 42);
	assert(opts.tos == 184);
	assert(strcmp(opts.source_ip, "127.0.0.1") == 0);
	assert(opts.interval_ms > 0.0 && opts.interval_ms < 600.0);
	assert(opts.timeout_ms > 1400.0 && opts.timeout_ms < 1600.0);
	assert(opts.deadline_ms > 3100.0 && opts.deadline_ms < 3300.0);
	assert(opts.payload_size == 64);
	assert(opts.pattern_len == 4);
	assert(opts.payload_pattern[0] == 0x0a && opts.payload_pattern[3] == 0x0d);
	assert(opts.stop_on_reply == 1);
	assert(opts.quiet == 1);
	assert(opts.verbose == 0);
	assert(strcmp(opts.target, "example.com") == 0);
}

static void	test_verbose_only(void)
{
	char *argv[] = {"ft_ping", "-v", "localhost", NULL};
	t_options opts;
	int ret = ft_parse_options(3, argv, &opts);
	assert(ret == 0);
	assert(opts.verbose == 1);
	assert(opts.count == -1);
	assert(opts.ttl == -1);
	assert(opts.quiet == 0);
	assert(strcmp(opts.target, "localhost") == 0);
}

static void	test_invalid_payload_pattern(void)
{
	char *argv[] = {"ft_ping", "-p", "zz", "example.com", NULL};
	t_options opts;
	int ret = ft_parse_options(4, argv, &opts);
	assert(ret != 0);
}

int	main(void)
{
	test_count_ttl_timeout_deadline_payload_pattern();
	test_verbose_only();
	test_invalid_payload_pattern();
	puts("options tests: OK");
	return (0);
}
