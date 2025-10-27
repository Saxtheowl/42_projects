#include "philo.h"

#include <limits.h>
#include <stdlib.h>
#include <unistd.h>

static void	write_error(const char *msg)
{
	size_t	len;

	len = 0;
	while (msg[len] != '\0')
		len++;
	write(2, msg, len);
}

int	ft_isdigit(int c)
{
	return (c >= '0' && c <= '9');
}

long	ft_atol(const char *str, int *ok)
{
	long	result;
	size_t	index;

	if (ok != NULL)
		*ok = 0;
	if (str == NULL || str[0] == '\0')
		return (0);
	index = 0;
	if (str[index] == '+')
		index++;
	if (str[index] == '\0')
		return (0);
	result = 0;
	while (str[index] != '\0')
	{
		if (!ft_isdigit((unsigned char)str[index]))
			return (0);
		result = (result * 10) + (str[index] - '0');
		if (result > INT_MAX)
			return (0);
		index++;
	}
	if (ok != NULL)
		*ok = 1;
	return (result);
}

static int	parse_value(const char *arg, int *out)
{
	long	value;
	int		ok;

	value = ft_atol(arg, &ok);
	if (!ok || value <= 0)
		return (0);
	*out = (int)value;
	return (1);
}

int	parse_config(int argc, char **argv, t_config *config)
{
	if (argc != 5 && argc != 6)
	{
		write_error("Error: invalid arguments\n");
		return (0);
	}
	if (!parse_value(argv[1], &config->philo_count)
		|| !parse_value(argv[2], &config->time_to_die)
		|| !parse_value(argv[3], &config->time_to_eat)
		|| !parse_value(argv[4], &config->time_to_sleep))
	{
		write_error("Error: arguments must be positive integers\n");
		return (0);
	}
	config->has_must_eat = 0;
	config->must_eat_target = 0;
	if (argc == 6)
	{
		if (!parse_value(argv[5], &config->must_eat_target))
		{
			write_error("Error: invalid eat count\n");
			return (0);
		}
		config->has_must_eat = 1;
	}
	return (1);
}
