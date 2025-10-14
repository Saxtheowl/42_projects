#include "libft.h"

#include <stdlib.h>

void    *ft_memset(void *b, int c, size_t len)
{
    unsigned char   *ptr;

    ptr = (unsigned char *)b;
    while (len--)
        *ptr++ = (unsigned char)c;
    return (b);
}

void    ft_bzero(void *s, size_t n)
{
    ft_memset(s, 0, n);
}

void    *ft_memcpy(void *dst, const void *src, size_t n)
{
    size_t              i;
    unsigned char       *d;
    const unsigned char *s;

    if (!dst && !src)
        return (NULL);
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

void    *ft_memccpy(void *dst, const void *src, int c, size_t n)
{
    unsigned char       *d;
    const unsigned char *s;
    size_t              i;

    if (!dst && !src)
        return (NULL);
    d = (unsigned char *)dst;
    s = (const unsigned char *)src;
    i = 0;
    while (i < n)
    {
        d[i] = s[i];
        if (s[i] == (unsigned char)c)
            return (d + i + 1);
        i++;
    }
    return (NULL);
}

void    *ft_memmove(void *dst, const void *src, size_t len)
{
    unsigned char       *d;
    const unsigned char *s;

    if (dst == src)
        return (dst);
    d = (unsigned char *)dst;
    s = (const unsigned char *)src;
    if (s < d && d < s + len)
    {
        while (len--)
            d[len] = s[len];
    }
    else
    {
        size_t i = 0;
        while (i < len)
        {
            d[i] = s[i];
            i++;
        }
    }
    return (dst);
}

void    *ft_memchr(const void *s, int c, size_t n)
{
    const unsigned char *ptr;
    size_t              i;

    ptr = (const unsigned char *)s;
    i = 0;
    while (i < n)
    {
        if (ptr[i] == (unsigned char)c)
            return ((void *)(ptr + i));
        i++;
    }
    return (NULL);
}

int ft_memcmp(const void *s1, const void *s2, size_t n)
{
    const unsigned char *a;
    const unsigned char *b;
    size_t              i;

    a = (const unsigned char *)s1;
    b = (const unsigned char *)s2;
    i = 0;
    while (i < n)
    {
        if (a[i] != b[i])
            return (a[i] - b[i]);
        i++;
    }
    return (0);
}

void    *ft_calloc(size_t count, size_t size)
{
    void *ptr;

    if (size != 0 && count > ((size_t)-1) / size)
        return (NULL);
    ptr = malloc(count * size);
    if (!ptr)
        return (NULL);
    ft_bzero(ptr, count * size);
    return (ptr);
}

char    *ft_strdup(const char *s1)
{
    size_t  len;
    char    *copy;
    size_t  i;

    len = ft_strlen(s1);
    copy = (char *)malloc(len + 1);
    if (!copy)
        return (NULL);
    i = 0;
    while (i < len)
    {
        copy[i] = s1[i];
        i++;
    }
    copy[i] = '\0';
    return (copy);
}
