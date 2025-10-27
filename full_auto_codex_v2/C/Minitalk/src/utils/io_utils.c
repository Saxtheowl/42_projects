#include "minitalk.h"

#include <unistd.h>

static void	put_positive(long n, int fd)
{
	char	c;

	if (n >= 10)
		put_positive(n / 10, fd);
	c = '0' + (n % 10);
	write(fd, &c, 1);
}

void	ft_putstr_fd(const char *s, int fd)
{
	if (s == NULL)
		return ;
	write(fd, s, ft_strlen(s));
}

void	ft_putnbr_fd(int n, int fd)
{
	long	value;

	value = (long)n;
	if (value < 0)
	{
		write(fd, "-", 1);
		value = -value;
	}
	put_positive(value, fd);
}

