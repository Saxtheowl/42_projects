#include "ft_ping.h"

#include <stdio.h>
#include <stdlib.h>

static void	print_usage(const char *prog)
{
	printf("Usage: %s [-hvqDRO] [-c count] [-t ttl] [-Q tos] [-S source] [-i interval] [-W timeout] [-w deadline] [-s size] [-p hexpattern] destination\n", prog);
	printf("  -h  display this help and exit\n");
	printf("  -v  verbose output (print packet details and ICMP errors)\n");
	printf("  -q  quiet output (suppress per-packet lines)\n");
	printf("  -c  stop after sending <count> echo requests\n");
	printf("  -t  set outgoing TTL (1-255, default %d)\n", FT_PING_DEFAULT_TTL);
	printf("  -Q  set IP TOS/DSCP byte (0-255)\n");
	printf("  -S  set source IPv4 address to bind\n");
	printf("  -i  set interval between requests in seconds (default 1s)\n");
	printf("  -W  set per-request timeout in seconds (default 1s)\n");
	printf("  -w  set an overall deadline in seconds (stop after this time)\n");
	printf("  -s  set payload size in bytes (default %d)\n", FT_PING_DEFAULT_PAYLOAD_SIZE);
	printf("  -p  provide payload pattern as hex (repeated after timestamp)\n");
	printf("  -D  print timestamp (epoch ms) before each output line\n");
	printf("  -R  resolve reverse DNS for replies when possible\n");
	printf("  -O  stop after the first received reply\n");
}

static const char	*prog_name(const char *path)
{
	size_t	len;

	len = ft_strlen(path);
	while (len > 0)
	{
		if (path[len - 1] == '/')
			return (path + len);
		len--;
	}
	return (path);
}

int	ft_parse_options(int argc, char **argv, t_options *opts)
{
	int	i;

	if (!opts)
		return (-1);
	opts->target = NULL;
	opts->source_ip = NULL;
	opts->verbose = 0;
	opts->count = -1;
	opts->ttl = -1;
	opts->tos = -1;
	opts->interval_ms = -1.0;
	opts->timeout_ms = -1.0;
	opts->deadline_ms = -1.0;
	opts->payload_size = FT_PING_DEFAULT_PAYLOAD_SIZE;
	opts->pattern_len = 0;
	opts->quiet = 0;
	opts->print_timestamp = 0;
	opts->resolve_reply = 0;
	opts->stop_on_reply = 0;
	i = 1;
	while (i < argc)
	{
		if (ft_strcmp(argv[i], "-h") == 0 || ft_strcmp(argv[i], "--help") == 0)
		{
			print_usage(prog_name(argv[0]));
			return (1);
		}
		else if (ft_strcmp(argv[i], "-v") == 0)
			opts->verbose = 1;
		else if (ft_strcmp(argv[i], "-D") == 0)
			opts->print_timestamp = 1;
		else if (ft_strcmp(argv[i], "-R") == 0)
			opts->resolve_reply = 1;
		else if (ft_strcmp(argv[i], "-q") == 0)
			opts->quiet = 1;
		else if (ft_strcmp(argv[i], "-S") == 0)
		{
			if (i + 1 >= argc)
			{
				fprintf(stderr, "%s: option requires an argument -- S\n",
					prog_name(argv[0]));
				return (-1);
			}
			opts->source_ip = argv[i + 1];
			i++;
		}
		else if (ft_strcmp(argv[i], "-c") == 0)
		{
			long	value;
			int		ok;

			if (i + 1 >= argc)
			{
				fprintf(stderr, "%s: option requires an argument -- c\n",
					prog_name(argv[0]));
				return (-1);
			}
			value = ft_atol(argv[i + 1], &ok);
			if (!ok || value <= 0)
			{
				fprintf(stderr, "%s: invalid count '%s'\n",
					prog_name(argv[0]), argv[i + 1]);
				return (-1);
			}
			opts->count = value;
			i++;
		}
		else if (ft_strcmp(argv[i], "-t") == 0)
		{
			long	value;
			int		ok;

			if (i + 1 >= argc)
			{
				fprintf(stderr, "%s: option requires an argument -- t\n",
					prog_name(argv[0]));
				return (-1);
			}
			value = ft_atol(argv[i + 1], &ok);
			if (!ok || value < 1 || value > 255)
			{
				fprintf(stderr, "%s: invalid ttl '%s' (must be 1-255)\n",
					prog_name(argv[0]), argv[i + 1]);
				return (-1);
			}
			opts->ttl = (int)value;
			i++;
		}
		else if (ft_strcmp(argv[i], "-Q") == 0)
		{
			long	value;
			int		ok;

			if (i + 1 >= argc)
			{
				fprintf(stderr, "%s: option requires an argument -- Q\n",
					prog_name(argv[0]));
				return (-1);
			}
			value = ft_atol(argv[i + 1], &ok);
			if (!ok || value < 0 || value > 255)
			{
				fprintf(stderr, "%s: invalid tos '%s' (must be 0-255)\n",
					prog_name(argv[0]), argv[i + 1]);
				return (-1);
			}
			opts->tos = (int)value;
			i++;
		}
		else if (ft_strcmp(argv[i], "-i") == 0)
		{
			char	*end;
			double	val;

			if (i + 1 >= argc)
			{
				fprintf(stderr, "%s: option requires an argument -- i\n",
					prog_name(argv[0]));
				return (-1);
			}
			val = strtod(argv[i + 1], &end);
			if (end == argv[i + 1] || val <= 0.0)
			{
				fprintf(stderr, "%s: invalid interval '%s'\n",
					prog_name(argv[0]), argv[i + 1]);
				return (-1);
			}
			opts->interval_ms = val * 1000.0;
			i++;
		}
		else if (ft_strcmp(argv[i], "-W") == 0)
		{
			char	*end;
			double	val;

			if (i + 1 >= argc)
			{
				fprintf(stderr, "%s: option requires an argument -- W\n",
					prog_name(argv[0]));
				return (-1);
			}
			val = strtod(argv[i + 1], &end);
			if (end == argv[i + 1] || val <= 0.0)
			{
				fprintf(stderr, "%s: invalid timeout '%s'\n",
					prog_name(argv[0]), argv[i + 1]);
				return (-1);
			}
			opts->timeout_ms = val * 1000.0;
			i++;
		}
		else if (ft_strcmp(argv[i], "-w") == 0)
		{
			char	*end;
			double	val;

			if (i + 1 >= argc)
			{
				fprintf(stderr, "%s: option requires an argument -- w\n",
					prog_name(argv[0]));
				return (-1);
			}
			val = strtod(argv[i + 1], &end);
			if (end == argv[i + 1] || val <= 0.0)
			{
				fprintf(stderr, "%s: invalid deadline '%s'\n",
					prog_name(argv[0]), argv[i + 1]);
				return (-1);
			}
			opts->deadline_ms = val * 1000.0;
			i++;
		}
		else if (ft_strcmp(argv[i], "-s") == 0)
		{
			long	value;
			int		ok;

			if (i + 1 >= argc)
			{
				fprintf(stderr, "%s: option requires an argument -- s\n",
					prog_name(argv[0]));
				return (-1);
			}
			value = ft_atol(argv[i + 1], &ok);
			if (!ok || value < (long)sizeof(struct timeval) || value > FT_PING_MAX_PAYLOAD_SIZE)
			{
				fprintf(stderr, "%s: invalid payload size '%s' (must be between %zu and %d)\n",
					prog_name(argv[0]), argv[i + 1], sizeof(struct timeval), FT_PING_MAX_PAYLOAD_SIZE);
				return (-1);
			}
			opts->payload_size = (size_t)value;
			i++;
		}
		else if (ft_strcmp(argv[i], "-p") == 0)
		{
			size_t	len;
			size_t	j;

			if (i + 1 >= argc)
			{
				fprintf(stderr, "%s: option requires an argument -- p\n",
					prog_name(argv[0]));
				return (-1);
			}
			len = ft_strlen(argv[i + 1]);
			if (len == 0 || (len % 2) != 0)
			{
				fprintf(stderr, "%s: pattern must be a non-empty even-length hex string\n",
					prog_name(argv[0]));
				return (-1);
			}
			if (len / 2 > FT_PING_MAX_PAYLOAD_SIZE)
			{
				fprintf(stderr, "%s: pattern too long (max %d bytes)\n",
					prog_name(argv[0]), FT_PING_MAX_PAYLOAD_SIZE);
				return (-1);
			}
			opts->pattern_len = len / 2;
			j = 0;
			while (j < opts->pattern_len)
			{
				char	hex[3];
				char	*end;
				long	val;

				hex[0] = argv[i + 1][j * 2];
				hex[1] = argv[i + 1][j * 2 + 1];
				hex[2] = '\0';
				val = strtol(hex, &end, 16);
				if (end != hex + 2 || val < 0 || val > 255)
				{
					fprintf(stderr, "%s: invalid hex in pattern\n", prog_name(argv[0]));
					return (-1);
				}
				opts->payload_pattern[j] = (unsigned char)val;
				j++;
			}
			i++;
		}
		else if (ft_strcmp(argv[i], "-D") == 0)
			opts->print_timestamp = 1;
		else if (ft_strcmp(argv[i], "-R") == 0)
			opts->resolve_reply = 1;
		else if (ft_strcmp(argv[i], "-O") == 0)
			opts->stop_on_reply = 1;
		else if (argv[i][0] == '-')
		{
			fprintf(stderr, "%s: invalid option -- %s\n",
				prog_name(argv[0]), argv[i]);
			print_usage(prog_name(argv[0]));
			return (-1);
		}
		else if (!opts->target)
			opts->target = argv[i];
		else
		{
			fprintf(stderr, "%s: extra operand -- %s\n",
				prog_name(argv[0]), argv[i]);
			print_usage(prog_name(argv[0]));
			return (-1);
		}
		i++;
	}
	if (!opts->target)
	{
		print_usage(prog_name(argv[0]));
		return (-1);
	}
	return (0);
}
