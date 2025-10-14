#include "libft.h"

size_t  ft_strlen(const char *s)
{
    size_t len = 0;

    while (s && s[len])
        len++;
    return (len);
}

size_t  ft_strlcpy(char *dst, const char *src, size_t dstsize)
{
    size_t i;
    size_t src_len;

    if (!dst && !src)
        return (0);
    src_len = ft_strlen(src);
    if (dstsize == 0)
        return (src_len);
    i = 0;
    while (src[i] && i + 1 < dstsize)
    {
        dst[i] = src[i];
        i++;
    }
    dst[i] = '\0';
    return (src_len);
}

size_t  ft_strlcat(char *dst, const char *src, size_t dstsize)
{
    size_t dst_len;
    size_t src_len;
    size_t i;

    dst_len = ft_strlen(dst);
    src_len = ft_strlen(src);
    if (dst_len >= dstsize)
        return (dstsize + src_len);
    i = 0;
    while (src[i] && dst_len + i + 1 < dstsize)
    {
        dst[dst_len + i] = src[i];
        i++;
    }
    dst[dst_len + i] = '\0';
    return (dst_len + src_len);
}

char    *ft_strchr(const char *s, int c)
{
    while (*s)
    {
        if (*s == (char)c)
            return ((char *)s);
        s++;
    }
    if ((char)c == '\0')
        return ((char *)s);
    return (NULL);
}

char    *ft_strrchr(const char *s, int c)
{
    const char  *last = NULL;

    while (*s)
    {
        if (*s == (char)c)
            last = s;
        s++;
    }
    if ((char)c == '\0')
        return ((char *)s);
    return ((char *)last);
}

char    *ft_strnstr(const char *haystack, const char *needle, size_t len)
{
    size_t needle_len;
    size_t i;

    if (*needle == '\0')
        return ((char *)haystack);
    needle_len = ft_strlen(needle);
    if (needle_len == 0)
        return ((char *)haystack);
    i = 0;
    while (haystack[i] && i + needle_len <= len)
    {
        if (haystack[i] == needle[0] &&
            ft_strncmp(haystack + i, needle, needle_len) == 0)
            return ((char *)(haystack + i));
        i++;
    }
    return (NULL);
}

int ft_strncmp(const char *s1, const char *s2, size_t n)
{
    size_t i;

    if (n == 0)
        return (0);
    i = 0;
    while (i + 1 < n && s1[i] && s2[i] && s1[i] == s2[i])
        i++;
    return ((unsigned char)s1[i] - (unsigned char)s2[i]);
}
