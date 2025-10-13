#include "libft.h"

#include <stdlib.h>
#include <unistd.h>

size_t	ft_strlen(const char *s)
{
	size_t	len;

	if (s == NULL)
		return (0);
	len = 0;
	while (s[len] != '\0')
		len++;
	return (len);
}

int	ft_strcmp(const char *s1, const char *s2)
{
	size_t	i;

	i = 0;
	while (s1[i] != '\0' && s2[i] != '\0' && s1[i] == s2[i])
		i++;
	return ((unsigned char)s1[i] - (unsigned char)s2[i]);
}

int	ft_strncmp(const char *s1, const char *s2, size_t n)
{
	size_t	i;

	if (n == 0)
		return (0);
	i = 0;
	while (i + 1 < n && s1[i] != '\0' && s2[i] != '\0' && s1[i] == s2[i])
		i++;
	return ((unsigned char)s1[i] - (unsigned char)s2[i]);
}

void	*ft_memcpy(void *dst, const void *src, size_t n)
{
	size_t			 i;
	unsigned char	*dest;
	const unsigned char	*source;

	if (dst == NULL && src == NULL)
		return (NULL);
	dest = (unsigned char *)dst;
	source = (const unsigned char *)src;
	i = 0;
	while (i < n)
	{
		dest[i] = source[i];
		i++;
	}
	return (dst);
}

void	ft_bzero(void *s, size_t n)
{
	size_t		 i;
	unsigned char	*ptr;

	ptr = (unsigned char *)s;
	i = 0;
	while (i < n)
	{
		ptr[i] = 0;
		i++;
	}
}

void	*ft_calloc(size_t count, size_t size)
{
	void	*ptr;
	size_t	total;

	total = count * size;
	if (count != 0 && total / count != size)
		return (NULL);
	ptr = malloc(total);
	if (ptr == NULL)
		return (NULL);
	ft_bzero(ptr, total);
	return (ptr);
}

void	ft_putstr_fd(const char *s, int fd)
{
	if (s == NULL)
		return ;
	write(fd, s, ft_strlen(s));
}

void	ft_putendl_fd(const char *s, int fd)
{
	ft_putstr_fd(s, fd);
	write(fd, "\n", 1);
}

void	ft_putchar_fd(char c, int fd)
{
	write(fd, &c, 1);
}
