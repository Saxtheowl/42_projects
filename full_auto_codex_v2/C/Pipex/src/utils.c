#include "pipex.h"

#include <stdlib.h>

size_t px_strlen(const char *s)
{
    size_t i = 0;

    if (!s)
        return (0);
    while (s[i])
        i++;
    return (i);
}

char *px_strdup(const char *s)
{
    size_t  len;
    char    *out;
    size_t  i;

    if (!s)
        return (NULL);
    len = px_strlen(s);
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

char *px_strjoin(const char *s1, const char *s2)
{
    size_t  len1;
    size_t  len2;
    char    *out;
    size_t  i;

    len1 = px_strlen(s1);
    len2 = px_strlen(s2);
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

char *px_substr(const char *s, size_t start, size_t len)
{
    char    *out;
    size_t  i;

    if (!s)
        return (NULL);
    if (start >= px_strlen(s))
        return (px_strdup(""));
    if (len > px_strlen(s + start))
        len = px_strlen(s + start);
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

int px_strncmp(const char *s1, const char *s2, size_t n)
{
    size_t i;

    if (n == 0)
        return (0);
    i = 0;
    while (i + 1 < n && s1[i] && s2[i] && s1[i] == s2[i])
        i++;
    return ((unsigned char)s1[i] - (unsigned char)s2[i]);
}

void px_free_split(char **split)
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
