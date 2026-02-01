#include "bsq.h"

int str_len(const char *s)
{
    int len;

    if (!s)
        return (0);
    len = 0;
    while (s[len])
        len++;
    return (len);
}

int str_to_int(const char *s, int *end_pos)
{
    int result;
    int i;

    result = 0;
    i = 0;
    while (s[i] >= '0' && s[i] <= '9')
    {
        result = result * 10 + (s[i] - '0');
        i++;
    }
    *end_pos = i;
    return (result);
}

static int count_lines(char *content)
{
    int count;
    int i;

    count = 0;
    i = 0;
    while (content[i])
    {
        if (content[i] == '\n')
            count++;
        i++;
    }
    if (i > 0 && content[i - 1] != '\n')
        count++;
    return (count);
}

static char *duplicate_line(const char *start, int len)
{
    char    *line;
    int     i;

    line = malloc(len + 1);
    if (!line)
        return (NULL);
    i = 0;
    while (i < len)
    {
        line[i] = start[i];
        i++;
    }
    line[len] = '\0';
    return (line);
}

char **split_lines(char *content, int *line_count)
{
    char    **lines;
    int     count;
    int     i;
    int     start;
    int     idx;

    count = count_lines(content);
    *line_count = count;
    lines = malloc(sizeof(char *) * (count + 1));
    if (!lines)
        return (NULL);
    i = 0;
    start = 0;
    idx = 0;
    while (content[i])
    {
        if (content[i] == '\n')
        {
            lines[idx++] = duplicate_line(&content[start], i - start);
            start = i + 1;
        }
        i++;
    }
    if (start < i)
        lines[idx++] = duplicate_line(&content[start], i - start);
    lines[idx] = NULL;
    return (lines);
}

void free_lines(char **lines, int count)
{
    int i;

    if (!lines)
        return;
    i = 0;
    while (i < count)
    {
        free(lines[i]);
        i++;
    }
    free(lines);
}
