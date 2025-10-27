#include "ft_ping.h"

#include <stdio.h>

static void	print_usage(const char *prog)
{
	printf("Usage: %s [-hv] destination\n", prog);
	printf("  -h  display this help and exit\n");
	printf("  -v  verbose output (print packet details and ICMP errors)\n");
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
	opts->verbose = 0;
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
