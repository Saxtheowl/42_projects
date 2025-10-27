#include "ft_ping.h"

double	ft_time_diff_ms(const struct timeval *start, const struct timeval *end)
{
	double	sec;
	double	usec;

	if (!start || !end)
		return (0.0);
	sec = (double)(end->tv_sec - start->tv_sec);
	usec = (double)(end->tv_usec - start->tv_usec);
	return (sec * 1000.0) + (usec / 1000.0);
}

size_t	ft_strlen(const char *s)
{
	size_t	len;

	if (!s)
		return (0);
	len = 0;
	while (s[len] != '\0')
		len++;
	return (len);
}

int	ft_strcmp(const char *s1, const char *s2)
{
	size_t	i;

	if (s1 == s2)
		return (0);
	i = 0;
	while (s1 && s2 && s1[i] != '\0' && s2[i] != '\0')
	{
		if (s1[i] != s2[i])
			return ((unsigned char)s1[i] - (unsigned char)s2[i]);
		i++;
	}
	if (!s1 || !s2)
		return (s1 ? 1 : -1);
	return ((unsigned char)s1[i] - (unsigned char)s2[i]);
}

int	ft_strncmp(const char *s1, const char *s2, size_t n)
{
	size_t	i;

	if (n == 0)
		return (0);
	i = 0;
	while (s1 && s2 && s1[i] != '\0' && s2[i] != '\0' && i + 1 < n)
	{
		if (s1[i] != s2[i])
			return ((unsigned char)s1[i] - (unsigned char)s2[i]);
		i++;
	}
	if (!s1 || !s2)
		return (s1 ? 1 : -1);
	return ((unsigned char)s1[i] - (unsigned char)s2[i]);
}

size_t	ft_strlcpy(char *dst, const char *src, size_t size)
{
	size_t	i;

	if (!dst || !src)
		return (0);
	i = 0;
	if (size > 0)
	{
		while (src[i] != '\0' && i + 1 < size)
		{
			dst[i] = src[i];
			i++;
		}
		if (size > 0)
			dst[i] = '\0';
	}
	while (src[i] != '\0')
		i++;
	return (i);
}

void	*ft_memcpy(void *dst, const void *src, size_t n)
{
	size_t			i;
	unsigned char	*d;
	const unsigned char	*s;

	if (!dst || !src)
		return (dst);
	d = (unsigned char *)dst;
	s = (const unsigned char *)src;
	i = 0;
	while (i < n)
	{
		d[i] = s[i];
		i++;
	}
	return (dst);
}

int	ft_isdigit(int c)
{
	return (c >= '0' && c <= '9');
}

long	ft_atol(const char *str, int *ok)
{
	long	result;
	long	sign;
	size_t	i;

	if (ok)
		*ok = 0;
	if (!str)
		return (0);
	i = 0;
	while (str[i] == ' ' || str[i] == '\t' || str[i] == '\n'
		|| str[i] == '\r' || str[i] == '\f' || str[i] == '\v')
		i++;
	sign = 1;
	if (str[i] == '+' || str[i] == '-')
	{
		if (str[i] == '-')
			sign = -1;
		i++;
	}
	if (!ft_isdigit(str[i]))
		return (0);
	result = 0;
	while (ft_isdigit(str[i]))
	{
		result = (result * 10) + (str[i] - '0');
		i++;
	}
	if (ok)
		*ok = (str[i] == '\0');
	return (result * sign);
}

void	ft_bzero(void *ptr, size_t len)
{
	ft_memset(ptr, 0, len);
}

void	*ft_memset(void *ptr, int value, size_t len)
{
	size_t			i;
	unsigned char	*dst;

	dst = (unsigned char *)ptr;
	i = 0;
	while (i < len)
	{
		dst[i] = (unsigned char)value;
		i++;
	}
	return (ptr);
}
