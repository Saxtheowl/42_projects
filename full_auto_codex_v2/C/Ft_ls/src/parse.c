#include "ft_ls.h"

#include <stdio.h>
#include <string.h>

static int	add_flag(t_options *opts, char flag)
{
	if (flag == 'l')
		opts->flags |= FT_LS_OPT_L;
	else if (flag == 'R')
		opts->flags |= FT_LS_OPT_R_UPPER;
	else if (flag == 'a')
		opts->flags |= FT_LS_OPT_A;
	else if (flag == 'r')
		opts->flags |= FT_LS_OPT_R;
	else if (flag == 't')
		opts->flags |= FT_LS_OPT_T;
	else
	{
		fprintf(stderr, "ft_ls: illegal option -- %c\n", flag);
		fprintf(stderr, "usage: ft_ls [-lRat] [file ...]\n");
		return (-1);
	}
	return (0);
}

static int	parse_option_string(const char *arg, t_options *opts)
{
	size_t	index;

	if (strcmp(arg, "--") == 0)
		return (1);
	index = 1;
	while (arg[index] != '\0')
	{
		if (add_flag(opts, arg[index]) != 0)
			return (-1);
		index++;
	}
	return (0);
}

int	parse_options(int argc, char **argv, t_options *opts, int *first_path)
{
	int	i;
	int	result;

	if (opts == NULL || first_path == NULL)
		return (-1);
	opts->flags = 0;
	i = 1;
	while (i < argc && argv[i][0] == '-' && argv[i][1] != '\0')
	{
		result = parse_option_string(argv[i], opts);
		if (result == -1)
			return (-1);
		if (result == 1)
		{
			i++;
			break ;
		}
		i++;
	}
	*first_path = i;
	return (0);
}
