#include "ft_otool.h"

int	main(int argc, char **argv)
{
	int	index;
	int	error;

	error = 0;
	if (argc <= 1)
		return (ft_otool_process("a.out"));
	index = 1;
	while (index < argc)
	{
		if (ft_otool_process(argv[index]) != 0)
			error = 1;
		index++;
	}
	return (error);
}
