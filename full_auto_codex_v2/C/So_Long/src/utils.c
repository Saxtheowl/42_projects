#include "so_long.h"

#include <stdlib.h>
#include <unistd.h>

size_t sl_strlen(const char *s)
{
    size_t len = 0;

    if (!s)
        return (0);
    while (s[len])
        len++;
    return (len);
}

char    *sl_strdup(const char *s)
{
    size_t  len;
    char    *out;
    size_t  i;

    len = sl_strlen(s);
    out = (char *)malloc(len + 1);
    if (!out)
        return (NULL);
    i = 0;
    while (i < len)
    {
        out[i] = s[i];
        i++;
    }
    out[i] = '\0';
    return (out);
}

char	*sl_substr(const char *s, size_t start, size_t len)
{
	char	*out;
	size_t	i;

	if (!s)
		return (NULL);
	if (start >= sl_strlen(s))
		return (sl_strdup(""));
	if (len > sl_strlen(s + start))
		len = sl_strlen(s + start);
	out = (char *)malloc(len + 1);
	if (!out)
		return (NULL);
	i = 0;
	while (i < len)
	{
		out[i] = s[start + i];
		i++;
	}
	out[i] = '\0';
	return (out);
}

char    *sl_strjoin(char const *s1, char const *s2)
{
    size_t  len1;
    size_t  len2;
    char    *out;
    size_t  i;

    len1 = sl_strlen(s1);
    len2 = sl_strlen(s2);
    out = (char *)malloc(len1 + len2 + 1);
    if (!out)
        return (NULL);
    i = 0;
    if (s1)
        while (*s1)
            out[i++] = *s1++;
    if (s2)
        while (*s2)
            out[i++] = *s2++;
    out[i] = '\0';
    return (out);
}

char    **sl_split_lines(const char *s)
{
    size_t  i;
    size_t  start;
    size_t  count;
    char    **out;

    if (!s)
        return (NULL);
    count = 0;
    i = 0;
    while (s[i])
    {
        if (s[i] == '\n')
            count++;
        i++;
    }
    if (i > 0 && s[i - 1] != '\n')
        count++;
    out = (char **)malloc(sizeof(char *) * (count + 1));
    if (!out)
        return (NULL);
    i = 0;
    start = 0;
    count = 0;
    while (s[i])
    {
        if (s[i] == '\n')
        {
            out[count++] = sl_substr(s, start, i - start);
            start = i + 1;
        }
        i++;
    }
    if (i > start)
        out[count++] = sl_substr(s, start, i - start);
    if (count == 0)
        out[count++] = sl_strdup("");
    out[count] = NULL;
    return (out);
}

void    sl_free_split(char **split)
{
    size_t i;

    if (!split)
        return ;
    i = 0;
    while (split[i])
    {
        free(split[i]);
        i++;
    }
    free(split);
}

void    sl_putstr_fd(const char *s, int fd)
{
    if (s)
        write(fd, s, sl_strlen(s));
}

void    sl_putnbr_fd(size_t n, int fd)
{
    char    buffer[20];
    int     len;

    len = 0;
    if (n == 0)
        buffer[len++] = '0';
    while (n > 0)
    {
        buffer[len++] = '0' + (n % 10);
        n /= 10;
    }
    while (len-- > 0)
        write(fd, &buffer[len], 1);
}
