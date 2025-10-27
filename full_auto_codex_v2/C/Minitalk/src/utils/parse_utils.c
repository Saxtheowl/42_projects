#include "minitalk.h"

#include <limits.h>

static int	is_digit_string(const char *str)
{
	size_t	index;

	if (str == NULL || str[0] == '\0')
		return (0);
	index = 0;
	while (str[index] != '\0')
	{
		if (!ft_isdigit((unsigned char)str[index]))
			return (0);
		index++;
	}
	return (1);
}

int	parse_pid(const char *str, pid_t *pid)
{
	size_t	index;
	long	value;

	if (pid == NULL || !is_digit_string(str))
		return (0);
	value = 0;
	index = 0;
	while (str[index] != '\0')
	{
		value = (value * 10) + (str[index] - '0');
		if (value > INT_MAX)
			return (0);
		index++;
	}
	if (value <= 0)
		return (0);
	*pid = (pid_t)value;
	return (1);
}

