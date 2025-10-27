#include "ft_ls.h"

#include <stdio.h>

int main(int argc, char **argv)
{
	t_options opts;
	int first_path;
	int status;

	opts.flags = 0;
	first_path = 1;
	if (parse_options(argc, argv, &opts, &first_path) != 0)
		return (1);
	status = process_paths(argc, argv, &opts, first_path);
	return (status);
}
