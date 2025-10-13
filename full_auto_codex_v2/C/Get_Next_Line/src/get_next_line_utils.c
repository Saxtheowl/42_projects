#include "get_next_line.h"

size_t gnl_strlen(const char *s)
{
    size_t len;

    if (!s)
        return (0);
    len = 0;
    while (s[len])
        len++;
    return (len);
}

char *gnl_strchr(const char *s, int c)
{
    if (!s)
        return (NULL);
    while (*s)
    {
        if (*s == (char)c)
            return ((char *)s);
        s++;
    }
    if (c == '\0')
        return ((char *)s);
    return (NULL);
}

char *gnl_strjoin(char const *s1, char const *s2)
{
    size_t  len1;
    size_t  len2;
    char    *out;
    size_t  i;

    if (!s1 && !s2)
        return (NULL);
    len1 = gnl_strlen(s1);
    len2 = gnl_strlen(s2);
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

char *gnl_substr(char const *s, size_t start, size_t len)
{
    char    *out;
    size_t  i;

    if (!s)
        return (NULL);
    if (start >= gnl_strlen(s))
        return (gnl_strjoin("", ""));
    if (len > gnl_strlen(s + start))
        len = gnl_strlen(s + start);
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
