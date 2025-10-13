#include "pipex.h"

#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>

static int  append_char(char **buf, size_t *len, size_t *cap, char c)
{
    char    *tmp;

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
    char    **tmp;

    tmp = (char **)realloc(*arr, sizeof(char *) * (*count + 2));
    if (!tmp)
        return (-1);
    *arr = tmp;
    (*arr)[*count] = token;
    (*count)++;
    (*arr)[*count] = NULL;
    return (0);
}

static int  finish_token(char **buf, size_t *len, size_t *cap, char ***arr, size_t *count)
{
    char *token;

    if (*len == 0)
        return (0);
    if (append_char(buf, len, cap, '\0') == -1)
        return (-1);
    token = px_strdup(*buf);
    free(*buf);
    *buf = NULL;
    *len = 0;
    *cap = 0;
    if (!token)
        return (-1);
    if (add_token(arr, count, token) == -1)
    {
        free(token);
        return (-1);
    }
    return (0);
}

char    **px_split_cmd(const char *cmd)
{
    size_t  i = 0;
    char    **result = NULL;
    size_t  count = 0;
    char    *buffer = NULL;
    size_t  len = 0;
    size_t  cap = 0;

    while (cmd && cmd[i])
    {
        while (cmd[i] && isspace((unsigned char)cmd[i]))
            i++;
        if (!cmd[i])
            break;
        while (cmd[i])
        {
            if (isspace((unsigned char)cmd[i]))
                break;
            if (cmd[i] == '\'' || cmd[i] == '"')
            {
                char quote = cmd[i++];
                while (cmd[i] && cmd[i] != quote)
                {
                    if (append_char(&buffer, &len, &cap, cmd[i]) == -1)
                    {
                        px_free_split(result);
                        free(buffer);
                        return (NULL);
                    }
                    i++;
                }
                if (cmd[i] == quote)
                    i++;
                continue;
            }
            if (append_char(&buffer, &len, &cap, cmd[i]) == -1)
            {
                px_free_split(result);
                free(buffer);
                return (NULL);
            }
            i++;
        }
        if (finish_token(&buffer, &len, &cap, &result, &count) == -1)
        {
            px_free_split(result);
            free(buffer);
            return (NULL);
        }
    }
    free(buffer);
    return (result);
}

char    **px_split_path(const char *path)
{
    size_t  i = 0;
    size_t  start;
    char    **result = NULL;
    size_t  count = 0;

    if (!path)
        return (NULL);
    while (1)
    {
        start = i;
        while (path[i] && path[i] != ':')
            i++;
        char *segment = px_substr(path, start, i - start);
        if (!segment)
        {
            px_free_split(result);
            return NULL;
        }
        if (add_token(&result, &count, segment) == -1)
        {
            px_free_split(result);
            free(segment);
            return (NULL);
        }
        if (!path[i])
            break;
        i++;
    }
    return (result);
}

char    *px_find_command(char **paths, const char *cmd)
{
    char    *candidate;
    char    *tmp;
    size_t  i;

    if (!cmd || !*cmd)
        return (NULL);
    if (cmd[0] == '/' || px_strncmp(cmd, "./", 2) == 0 || px_strncmp(cmd, "../", 3) == 0)
        return (px_strdup(cmd));
    for (i = 0; paths && paths[i]; ++i)
    {
        tmp = px_strjoin(paths[i], "/");
        if (!tmp)
            return (NULL);
        candidate = px_strjoin(tmp, cmd);
        free(tmp);
        if (!candidate)
            return (NULL);
        if (access(candidate, X_OK) == 0)
            return (candidate);
        free(candidate);
    }
    return (NULL);
}
