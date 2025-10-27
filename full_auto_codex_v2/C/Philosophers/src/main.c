#include "philo.h"

#include <stdlib.h>
#include <unistd.h>

static void	print_error(const char *msg)
{
	size_t	len;

	len = 0;
	while (msg[len] != '\0')
		len++;
	write(2, msg, len);
}

int	main(int argc, char **argv)
{
	t_config	config;
	t_sim		sim;

	if (!parse_config(argc, argv, &config))
		return (EXIT_FAILURE);
	if (!init_simulation(&sim, &config))
	{
		print_error("Error: failed to initialize simulation\n");
		return (EXIT_FAILURE);
	}
	if (!start_simulation(&sim))
	{
		print_error("Error: simulation aborted\n");
		destroy_simulation(&sim);
		return (EXIT_FAILURE);
	}
	destroy_simulation(&sim);
	return (EXIT_SUCCESS);
}
