#include <unistd.h>

static int	ft_strlen(const char *s)
{
	int len = 0;
	while (s[len])
		len++;
	return len;
}

static int	ft_atoi(const char *s)
{
	long result = 0;
	int sign = 1;

	while (*s == ' ' || (*s >= '\t' && *s <= '\r'))
		s++;
	if (*s == '+' || *s == '-')
	{
		if (*s == '-')
			sign = -1;
		s++;
	}
	while (*s >= '0' && *s <= '9')
	{
		result = result * 10 + (*s - '0');
		s++;
	}
	return (int)(result * sign);
}

static void	ft_putnbr(int n)
{
	char	buf[12];
	long	nb;
	int		pos;

	nb = n;
	if (nb == 0)
	{
		write(1, "0", 1);
		return ;
	}
	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	pos = 0;
	while (nb > 0)
	{
		buf[pos++] = '0' + (nb % 10);
		nb /= 10;
	}
	while (pos-- > 0)
		write(1, &buf[pos], 1);
}

int main(int argc, char **argv)
{
	int i;
	int sum;

	sum = 0;
	i = 1;
	while (i < argc)
	{
		sum += ft_atoi(argv[i]);
		i++;
	}
	ft_putnbr(sum);
	write(1, "\n", 1);
	return 0;
}
