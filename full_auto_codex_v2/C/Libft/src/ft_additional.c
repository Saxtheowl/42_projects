#include "libft.h"

#include <stdlib.h>

char    *ft_substr(char const *s, unsigned int start, size_t len)
{
    size_t  slen;
    char    *out;
    size_t  i;

    if (!s)
        return (NULL);
    slen = ft_strlen(s);
    if (start >= slen)
        return (ft_strdup(""));
    if (len > slen - start)
        len = slen - start;
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

char    *ft_strjoin(char const *s1, char const *s2)
{
    size_t  len1;
    size_t  len2;
    char    *out;
    size_t  i;

    if (!s1 && !s2)
        return (NULL);
    len1 = ft_strlen(s1);
    len2 = ft_strlen(s2);
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

static int  is_in_set(char c, const char *set)
{
    while (set && *set)
    {
        if (*set == c)
            return (1);
        set++;
    }
    return (0);
}

char    *ft_strtrim(char const *s1, char const *set)
{
    size_t  start;
    size_t  end;

    if (!s1)
        return (NULL);
    start = 0;
    while (s1[start] && is_in_set(s1[start], set))
        start++;
    end = ft_strlen(s1);
    while (end > start && is_in_set(s1[end - 1], set))
        end--;
    return (ft_substr(s1, start, end - start));
}

char    *ft_strmapi(char const *s, char (*f)(unsigned int, char))
{
    char    *out;
    size_t  len;
    size_t  i;

    if (!s || !f)
        return (NULL);
    len = ft_strlen(s);
    out = (char *)malloc(len + 1);
    if (!out)
        return (NULL);
    i = 0;
    while (i < len)
    {
        out[i] = f((unsigned int)i, s[i]);
        i++;
    }
    out[i] = '\0';
    return (out);
}

static size_t   count_digits(int n)
{
    size_t count;
    long   nb;

    nb = n;
    count = 1;
    if (nb < 0)
    {
        nb = -nb;
        count++;
    }
    while (nb >= 10)
    {
        nb /= 10;
        count++;
    }
    return (count);
}

char    *ft_itoa(int n)
{
    size_t  len;
    long    nb;
    char    *out;

    len = count_digits(n);
    out = (char *)malloc(len + 1);
    if (!out)
        return (NULL);
    nb = n;
    out[len] = '\0';
    if (nb < 0)
    {
        out[0] = '-';
        nb = -nb;
    }
    if (nb == 0)
        out[--len] = '0';
    while (nb > 0)
    {
        out[--len] = (char)('0' + (nb % 10));
        nb /= 10;
    }
    return (out);
}
