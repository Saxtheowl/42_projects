#include "ft_ping.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int	main(int argc, char **argv)
{
	t_options	opts;
	int			ret;

	ret = ft_parse_options(argc, argv, &opts);
	if (ret != 0)
		return (ret > 0 ? EXIT_SUCCESS : EXIT_FAILURE);
	if (getuid() != 0)
	{
		fprintf(stderr, "ft_ping: this program requires root privileges\n");
		return (EXIT_FAILURE);
	}
	if (ft_ping_run(&opts) != 0)
		return (EXIT_FAILURE);
	return (EXIT_SUCCESS);
}
