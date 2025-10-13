#include "ft_strace.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const char *resolve_executable(const char *cmd, char *buffer, size_t size)
{
    const char  *path;
    const char  *start;
    const char  *end;

    if (strchr(cmd, '/'))
        return (cmd);
    path = getenv("PATH");
    if (!path)
        return (cmd);
    start = path;
    while (*start)
    {
        size_t len;

        end = strchr(start, ':');
        if (!end)
            end = start + strlen(start);
        len = (size_t)(end - start);
        if (len + 1 + strlen(cmd) < size)
        {
            memcpy(buffer, start, len);
            buffer[len] = '/';
            strcpy(buffer + len + 1, cmd);
            if (access(buffer, X_OK) == 0)
                return (buffer);
        }
        if (*end == '\0')
            break ;
        start = end + 1;
    }
    return (cmd);
}

int main(int argc, char **argv, char **envp)
{
    t_trace_config  cfg;
    const char      *resolved;
    char            path_buffer[4096];

    if (argc < 2)
    {
        fprintf(stderr, "Usage: %s program [args...]\n", argv[0]);
        return (EXIT_FAILURE);
    }
    resolved = resolve_executable(argv[1], path_buffer, sizeof(path_buffer));
    if (detect_target_binary(resolved, &cfg) == -1)
    {
        cfg.is_64bit = sizeof(void *) == 8;
    }
    if (run_strace(&argv[1], envp, &cfg) == -1)
        return (EXIT_FAILURE);
    return (EXIT_SUCCESS);
}
