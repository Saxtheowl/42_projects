#include "ft_nm_otool.h"

#include <stdio.h>

int	main(int argc, char **argv)
{
	int	status;
	int	ret;

	status = 0;
	if (argc <= 1)
		return print_otool("a.out");
	for (int i = 1; i < argc; ++i)
	{
		ret = print_otool(argv[i]);
		if (ret != 0)
			status = ret;
		if (i + 1 < argc)
			printf("\n");
	}
	return status;
}
