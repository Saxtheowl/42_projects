#include "push_swap.h"

#include <ctype.h>
#include <limits.h>
#include <stdlib.h>
#include <unistd.h>

size_t ps_strlen(const char *s)
{
    size_t len = 0;

    if (!s)
        return (0);
    while (s[len])
        len++;
    return (len);
}

char *ps_strdup(const char *s)
{
    size_t  len;
    char    *out;
    size_t  i;

    if (!s)
        return (NULL);
    len = ps_strlen(s);
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

static int  append_char(char **buf, size_t *len, size_t *cap, char c)
{
    char *tmp;

    if (*len + 1 >= *cap)
    {
        size_t new_cap = (*cap == 0) ? 16 : (*cap * 2);
        tmp = (char *)realloc(*buf, new_cap);
        if (!tmp)
            return (-1);
        *buf = tmp;
        *cap = new_cap;
    }
    (*buf)[(*len)++] = c;
    return (0);
}

static int  add_token(char ***arr, size_t *count, char *token)
{
    char **tmp;

    tmp = (char **)realloc(*arr, sizeof(char *) * (*count + 2));
    if (!tmp)
        return (-1);
    *arr = tmp;
    (*arr)[*count] = token;
    (*count)++;
    (*arr)[*count] = NULL;
    return (0);
}

char    **ps_split(const char *s)
{
    size_t  i = 0;
    char    **result = NULL;
    size_t  count = 0;
    char    *buf = NULL;
    size_t  len = 0;
    size_t  cap = 0;

    while (s && s[i])
    {
        while (s[i] && isspace((unsigned char)s[i]))
            i++;
        if (!s[i])
            break;
        while (s[i] && !isspace((unsigned char)s[i]))
        {
            if (append_char(&buf, &len, &cap, s[i]) == -1)
            {
                ps_free_split(result);
                free(buf);
                return (NULL);
            }
            i++;
        }
        if (append_char(&buf, &len, &cap, '\0') == -1)
        {
            ps_free_split(result);
            free(buf);
            return (NULL);
        }
        if (add_token(&result, &count, ps_strdup(buf)) == -1)
        {
            ps_free_split(result);
            free(buf);
            return (NULL);
        }
        free(buf);
        buf = NULL;
        len = 0;
        cap = 0;
    }
    free(buf);
    return (result);
}

void ps_free_split(char **split)
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

long ps_atol(const char *s, int *ok)
{
    long    sign = 1;
    long    value = 0;

    if (ok)
        *ok = 0;
    if (!s)
        return (0);
    while (*s && isspace((unsigned char)*s))
        s++;
    if (*s == '+' || *s == '-')
    {
        if (*s == '-')
            sign = -1;
        s++;
    }
    if (!*s)
        return (0);
    if (!isdigit((unsigned char)*s))
        return (0);
    while (*s && isdigit((unsigned char)*s))
    {
        value = value * 10 + (*s - '0');
        if ((sign == 1 && value > INT_MAX) || (sign == -1 && -value < INT_MIN))
            return (0);
        s++;
    }
    while (*s && isspace((unsigned char)*s))
        s++;
    if (*s != '\0')
        return (0);
    if (ok)
        *ok = 1;
    return (value * sign);
}

int ps_strcmp(const char *s1, const char *s2)
{
    while (*s1 && *s2 && *s1 == *s2)
    {
        s1++;
        s2++;
    }
    return ((unsigned char)*s1 - (unsigned char)*s2);
}

void ps_putstr_fd(const char *s, int fd)
{
    if (s)
        write(fd, s, ps_strlen(s));
}

void ps_cleanup(t_program *ps)
{
    stack_clear(&ps->a);
    stack_clear(&ps->b);
}

void ps_record_op(const char *op)
{
    if (!op)
        return ;
    ps_putstr_fd(op, 1);
    ps_putstr_fd("\n", 1);
}
