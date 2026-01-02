#include "ft_nmap.h"

#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void	fill_default_ports(t_ports *ports)
{
	size_t	i;

	ports->count = 0;
	i = 1;
	while (i <= 1024 && ports->count < ports->capacity)
	{
		ports->values[ports->count] = (int)i;
		ports->count++;
		++i;
	}
}

static int	add_port_range(int start, int end, char *visited, t_ports *out)
{
	int	i;

	if (start < 1 || end > FT_NMAP_MAX_PORTS || start > end)
		return (-1);
	i = start;
	while (i <= end)
	{
		if (!visited[i])
		{
			visited[i] = 1;
			out->count++;
		}
		++i;
	}
	return (0);
}

static int	parse_port_number(const char *token, int *out)
{
	char	*endptr;
	long	val;

	if (!token || *token == '\0')
		return (-1);
	errno = 0;
	val = strtol(token, &endptr, 10);
	if (errno != 0 || *endptr != '\0')
		return (-1);
	if (val < 1 || val > FT_NMAP_MAX_PORTS)
		return (-1);
	*out = (int)val;
	return (0);
}

static int	parse_port_range(const char *token, int *start, int *end)
{
	const char	*dash;
	long		start_val;
	long		end_val;

	dash = strchr(token, '-');
	if (!dash || dash == token || *(dash + 1) == '\0')
		return (-1);
	for (const char *p = token; p < dash; ++p)
	{
		if (!isdigit((unsigned char)*p))
			return (-1);
	}
	for (const char *p = dash + 1; *p; ++p)
	{
		if (!isdigit((unsigned char)*p))
			return (-1);
	}
	start_val = strtol(token, NULL, 10);
	end_val = strtol(dash + 1, NULL, 10);
	if (start_val < 1 || end_val > FT_NMAP_MAX_PORTS || start_val > end_val)
		return (-1);
	*start = (int)start_val;
	*end = (int)end_val;
	return (0);
}

static int	parse_service_port(const char *token, int *out)
{
	struct servent	*se;
	int				port;

	if (!token || *token == '\0')
		return (-1);
	se = getservbyname(token, "tcp");
	if (!se)
		return (-1);
	port = (int)ntohs(se->s_port);
	if (port < 1 || port > FT_NMAP_MAX_PORTS)
		return (-1);
	*out = port;
	return (0);
}

static int	parse_tokens(char *str, char *visited, t_ports *out)
{
	char	*token;
	int		start;
	int		end;
	int		port;

	token = strtok(str, ", \t\r\n");
	while (token)
	{
		if (parse_port_range(token, &start, &end) == 0)
		{
			if (add_port_range(start, end, visited, out) != 0)
				return (-1);
		}
		else if (parse_port_number(token, &port) == 0
			|| parse_service_port(token, &port) == 0)
		{
			if (add_port_range(port, port, visited, out) != 0)
				return (-1);
		}
		else
			return (-1);
		token = strtok(NULL, ", \t\r\n");
	}
	return (0);
}

static int	flush_visited(char *visited, t_ports *out)
{
	out->count = 0;
	for (size_t i = 1; i <= FT_NMAP_MAX_PORTS && out->count < out->capacity; ++i)
	{
		if (visited[i])
		{
			out->values[out->count] = (int)i;
			out->count++;
		}
	}
	return (out->count > 0 ? 0 : -1);
}

int	parse_ports(const char *str, t_ports *out)
{
	char	 copy[4096];
	char	 visited[FT_NMAP_MAX_PORTS + 1];

	if (!str || !out)
		return (-1);
	memset(visited, 0, sizeof(visited));
	out->count = 0;
	strncpy(copy, str, sizeof(copy) - 1);
	copy[sizeof(copy) - 1] = '\0';
	if (parse_tokens(copy, visited, out) != 0)
		return (-1);
	return (flush_visited(visited, out));
}

static void	apply_exclude(t_ports *ports, const t_ports *exclude)
{
	char	remove[FT_NMAP_MAX_PORTS + 1];
	size_t	w;

	if (!exclude || exclude->count == 0)
		return ;
	memset(remove, 0, sizeof(remove));
	for (size_t i = 0; i < exclude->count; ++i)
	{
		int p = exclude->values[i];

		if (p >= 1 && p <= FT_NMAP_MAX_PORTS)
			remove[p] = 1;
	}
	w = 0;
	for (size_t i = 0; i < ports->count; ++i)
	{
		int p = ports->values[i];

		if (p < 1 || p > FT_NMAP_MAX_PORTS)
			continue ;
		if (remove[p])
			continue ;
		ports->values[w++] = p;
	}
	ports->count = w;
}

static void	fill_top_ports(t_ports *out, int top_n)
{
	static const int	top_ports[] = {
		80, 443, 22, 21, 25, 110, 143, 53, 123, 587, 993, 995, 8080, 3306,
		5432, 6379, 27017, 5900, 3389, 636, 389, 139, 445, 111, 2049, 53};
	static const size_t	top_ports_count = sizeof(top_ports) / sizeof(top_ports[0]);
	size_t				limit;

	out->count = 0;
	limit = (size_t)top_n;
	if (limit > top_ports_count)
		limit = top_ports_count;
	for (size_t i = 0; i < limit && out->count < out->capacity; ++i)
		out->values[out->count++] = top_ports[i];
}

int	parse_ports_file(const char *path, t_ports *out)
{
	FILE	*f;
	char	 visited[FT_NMAP_MAX_PORTS + 1];
	char	 line[4096];

	if (!path || !out)
		return (-1);
	if (strcmp(path, "-") == 0)
		f = fopen("/dev/stdin", "r");
	else
		f = fopen(path, "r");
	if (!f)
		return (-1);
	memset(visited, 0, sizeof(visited));
	out->count = 0;
	while (fgets(line, sizeof(line), f))
	{
		if (parse_tokens(line, visited, out) != 0)
		{
			fclose(f);
			return (-1);
		}
	}
	fclose(f);
	return (flush_visited(visited, out));
}

int	parse_options(int argc, char **argv, t_options *out)
{
	int		i;
	int		has_target;
	size_t	initial_ports_count;

	if (!out)
		return (-1);
	memset(out, 0, sizeof(*out));
	out->ports.capacity = FT_NMAP_MAX_PORTS;
	out->ports.values = malloc(sizeof(int) * out->ports.capacity);
	if (!out->ports.values)
		return (-1);
	out->exclude.capacity = FT_NMAP_MAX_PORTS;
	out->exclude.values = malloc(sizeof(int) * out->exclude.capacity);
	if (!out->exclude.values)
		return (-1);
	out->stop_on_open_count = 0;
	out->timeout_ms = FT_NMAP_DEFAULT_TIMEOUT_MS;
	out->yaml_path = NULL;
	out->html_path = NULL;
	out->xml_path = NULL;
	out->json_summary_path = NULL;
	out->summary_to_stderr = 0;
	out->open_list_path = NULL;
	out->max_inflight = 256;
	out->ai_family = AF_UNSPEC;
	out->retries = 0;
	out->inter_batch_delay_ms = 0;
	out->deadline_ms = 0;
	out->random_seed = 0;
	out->random_seed_set = 0;
	out->ip_override = NULL;
	out->ip_override_set = 0;
	out->progress_interval_ms = 0;
	out->stop_on_timeout_count = 0;
	out->retry_backoff_pct = 0;
	out->export_filter = FT_NMAP_EXPORT_ALL;
	out->md_path = NULL;
	out->dry_run = 0;
	out->version_only = 0;
	out->help_only = 0;
	out->targets_path = NULL;
	out->scan_type = FT_NMAP_SCAN_TCP;
	has_target = 0;
	i = 1;
	while (i < argc)
	{
		if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0)
		{
			out->help_only = 1;
			++i;
			continue ;
		}
		if (strcmp(argv[i], "-V") == 0 || strcmp(argv[i], "--version") == 0)
		{
			out->version_only = 1;
			++i;
			continue ;
		}
		if (strcmp(argv[i], "-k") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val < 1 || val > (int)FT_NMAP_MAX_PORTS)
				return (-1);
			out->top_n = (int)val;
			fill_top_ports(&out->ports, out->top_n);
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-t") == 0 && i + 1 < argc)
		{
			out->target = argv[i + 1];
			has_target = 1;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "--ip") == 0 && i + 1 < argc)
		{
			out->target = argv[i + 1];
			has_target = 1;
			i += 2;
			continue ;
		}
		if ((strcmp(argv[i], "-i") == 0 || strcmp(argv[i], "--file") == 0)
			&& i + 1 < argc)
		{
			out->targets_path = argv[i + 1];
			has_target = 1;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-p") == 0 && i + 1 < argc)
		{
			if (parse_ports(argv[i + 1], &out->ports) != 0)
				return (-1);
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "--ports") == 0 && i + 1 < argc)
		{
			if (parse_ports(argv[i + 1], &out->ports) != 0)
				return (-1);
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-P") == 0 && i + 1 < argc)
		{
			if (parse_ports_file(argv[i + 1], &out->ports) != 0)
			{
				if (strcmp(argv[i + 1], "-") == 0
					&& parse_ports_file("/dev/stdin", &out->ports) == 0)
				{
					i += 2;
					continue ;
				}
				return (-1);
			}
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-x") == 0 && i + 1 < argc)
		{
			if (parse_ports(argv[i + 1], &out->exclude) != 0)
				return (-1);
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-X") == 0 && i + 1 < argc)
		{
			if (parse_ports_file(argv[i + 1], &out->exclude) != 0)
			{
				if (strcmp(argv[i + 1], "-") == 0
					&& parse_ports_file("/dev/stdin", &out->exclude) == 0)
				{
					i += 2;
					continue ;
				}
				return (-1);
			}
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-T") == 0 && i + 1 < argc)
		{
			char	*endptr;

			errno = 0;
			out->timeout_ms = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || out->timeout_ms <= 0)
				return (-1);
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-c") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val < 1
				|| val > FT_NMAP_MAX_INFLIGHT)
				return (-1);
			out->max_inflight = (int)val;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "--speedup") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val < 1
				|| val > FT_NMAP_MAX_INFLIGHT)
				return (-1);
			out->max_inflight = (int)val;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-R") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val < 0 || val > 5)
				return (-1);
			out->retries = (int)val;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-b") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val < 0 || val > 500)
				return (-1);
			out->retry_backoff_pct = (int)val;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-q") == 0)
		{
			out->quiet = 1;
			i += 1;
			continue ;
		}
		if (strcmp(argv[i], "-F") == 0)
		{
			out->stop_on_open_count = 1;
			i += 1;
			continue ;
		}
		if (strcmp(argv[i], "-f") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val < 1)
				return (-1);
			out->stop_on_open_count = (int)val;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-O") == 0)
		{
			out->open_only = 1;
			i += 1;
			continue ;
		}
		if (strcmp(argv[i], "-u") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val < 1)
				return (-1);
			out->stop_on_timeout_count = (int)val;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-S") == 0)
		{
			out->show_service = 1;
			i += 1;
			continue ;
		}
		if (strcmp(argv[i], "-l") == 0)
		{
			out->list_table = 1;
			i += 1;
			continue ;
		}
		if (strcmp(argv[i], "-r") == 0)
		{
			out->randomize = 1;
			i += 1;
			continue ;
		}
		if (strcmp(argv[i], "-g") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val <= 0 || val > 60000)
				return (-1);
			out->progress_interval_ms = val;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-e") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val < 0 || val > UINT_MAX)
				return (-1);
			out->randomize = 1;
			out->random_seed = (unsigned int)val;
			out->random_seed_set = 1;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-I") == 0 && i + 1 < argc)
		{
			out->ip_override = argv[i + 1];
			out->ip_override_set = 1;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-4") == 0)
		{
			out->ai_family = AF_INET;
			i += 1;
			continue ;
		}
		if (strcmp(argv[i], "-6") == 0)
		{
			out->ai_family = AF_INET6;
			i += 1;
			continue ;
		}
		if (strcmp(argv[i], "-o") == 0 && i + 1 < argc)
		{
			out->json_path = argv[i + 1];
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-J") == 0 && i + 1 < argc)
		{
			out->json_summary_path = argv[i + 1];
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-C") == 0 && i + 1 < argc)
		{
			out->csv_path = argv[i + 1];
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-N") == 0 && i + 1 < argc)
		{
			out->ndjson_path = argv[i + 1];
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-Y") == 0 && i + 1 < argc)
		{
			out->yaml_path = argv[i + 1];
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-Z") == 0 && i + 1 < argc)
		{
			out->xml_path = argv[i + 1];
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-H") == 0 && i + 1 < argc)
		{
			out->html_path = argv[i + 1];
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-m") == 0 && i + 1 < argc)
		{
			out->md_path = argv[i + 1];
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-Q") == 0)
		{
			out->summary_to_stderr = 1;
			i += 1;
			continue ;
		}
		if (strcmp(argv[i], "-E") == 0 && i + 1 < argc)
		{
			const char	*val = argv[i + 1];

			if (strcmp(val, "all") == 0)
				out->export_filter = FT_NMAP_EXPORT_ALL;
			else if (strcmp(val, "open") == 0)
				out->export_filter = FT_NMAP_EXPORT_OPEN_ONLY;
			else if (strcmp(val, "known") == 0)
				out->export_filter = FT_NMAP_EXPORT_KNOWN;
			else
				return (-1);
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-L") == 0 && i + 1 < argc)
		{
			out->open_list_path = argv[i + 1];
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "--scan") == 0 && i + 1 < argc)
		{
			const char	*val = argv[i + 1];

			if (strcmp(val, "tcp") == 0 || strcmp(val, "connect") == 0)
				out->scan_type = FT_NMAP_SCAN_TCP;
			else if (strcmp(val, "udp") == 0)
				out->scan_type = FT_NMAP_SCAN_UDP;
			else
				return (-1);
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-w") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val < 0 || val > 60000)
				return (-1);
			out->inter_batch_delay_ms = val;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-M") == 0 && i + 1 < argc)
		{
			char	*endptr;
			long	val;

			errno = 0;
			val = strtol(argv[i + 1], &endptr, 10);
			if (errno != 0 || *endptr != '\0' || val <= 0)
				return (-1);
			out->deadline_ms = val;
			i += 2;
			continue ;
		}
		if (strcmp(argv[i], "-n") == 0)
		{
			out->dry_run = 1;
			i += 1;
			continue ;
		}
		return (-1);
	}
	if (out->version_only)
		return (0);
	if (out->help_only)
		return (0);
	if (!has_target)
		return (-1);
	if (out->target && out->targets_path)
		return (-1);
	if (out->ports.count == 0)
		fill_default_ports(&out->ports);
	initial_ports_count = out->ports.count;
	apply_exclude(&out->ports, &out->exclude);
	if (initial_ports_count > out->ports.count)
		out->excluded_count = initial_ports_count - out->ports.count;
	if (out->ports.count > FT_NMAP_MAX_SCAN_PORTS)
		return (-1);
	if ((out->json_path && strcmp(out->json_path, "-") == 0)
		|| (out->json_summary_path && strcmp(out->json_summary_path, "-") == 0)
		|| (out->csv_path && strcmp(out->csv_path, "-") == 0)
		|| (out->ndjson_path && strcmp(out->ndjson_path, "-") == 0)
		|| (out->yaml_path && strcmp(out->yaml_path, "-") == 0)
		|| (out->xml_path && strcmp(out->xml_path, "-") == 0)
		|| (out->open_list_path && strcmp(out->open_list_path, "-") == 0)
		|| (out->html_path && strcmp(out->html_path, "-") == 0)
		|| (out->md_path && strcmp(out->md_path, "-") == 0))
		out->summary_to_stderr = 1;
	return (0);
}

void	free_options(t_options *opts)
{
	if (!opts)
		return ;
	free(opts->ports.values);
	opts->ports.values = NULL;
	free(opts->exclude.values);
	opts->exclude.values = NULL;
}
