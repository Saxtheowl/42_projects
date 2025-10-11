#include "ft_nm_otool.h"

#include <stdio.h>

int	main(int argc, char **argv)
{
	int		ret;
	int		status;

	status = 0;
	if (argc <= 1)
		return print_nm("a.out");
	for (int i = 1; i < argc; ++i)
	{
		if (argc > 2)
		{
			if (i > 1)
				printf("\n");
			printf("%s:\n", argv[i]);
		}
		ret = print_nm(argv[i]);
		if (ret != 0)
			status = ret;
	}
	return status;
}
