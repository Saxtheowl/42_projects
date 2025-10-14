#include "libft.h"

#include <stdlib.h>

static size_t   count_words(const char *s, char c)
{
    size_t count = 0;
    int     in_word = 0;

    while (*s)
    {
        if (*s != c && !in_word)
        {
            in_word = 1;
            count++;
        }
        else if (*s == c)
            in_word = 0;
        s++;
    }
    return (count);
}

static char *dup_range(const char *start, size_t len)
{
    char    *word;
    size_t  i;

    word = (char *)malloc(len + 1);
    if (!word)
        return (NULL);
    i = 0;
    while (i < len)
    {
        word[i] = start[i];
        i++;
    }
    word[i] = '\0';
    return (word);
}

char    **ft_split(char const *s, char c)
{
    char        **result;
    size_t      words;
    size_t      index;
    const char  *start;

    if (!s)
        return (NULL);
    words = count_words(s, c);
    result = (char **)malloc(sizeof(char *) * (words + 1));
    if (!result)
        return (NULL);
    index = 0;
    while (*s)
    {
        while (*s && *s == c)
            s++;
        start = s;
        while (*s && *s != c)
            s++;
        if (s > start)
        {
            result[index] = dup_range(start, (size_t)(s - start));
            if (!result[index])
            {
                while (index > 0)
                    free(result[--index]);
                free(result);
                return (NULL);
            }
            index++;
        }
    }
    result[index] = NULL;
    return (result);
}
