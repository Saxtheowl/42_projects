#include "ft_nm.h"

#include <stdlib.h>

int	main(int argc, char **argv)
{
	int	index;
	int	error;
	int	print_header;

	error = 0;
	if (argc <= 1)
	{
		if (ft_nm_process("a.out", 0) != 0)
			error = 1;
		return (error);
	}
	print_header = (argc > 2);
	index = 1;
	while (index < argc)
	{
		if (ft_nm_process(argv[index], print_header) != 0)
			error = 1;
		index++;
	}
	return (error);
}
