#include "pipex.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

void px_perror(const char *context)
{
    if (context && *context)
        fprintf(stderr, "pipex: %s: %s\n", context, strerror(errno));
    else
        fprintf(stderr, "pipex: %s\n", strerror(errno));
}

void px_cleanup(t_pipex *px)
{
    if (!px)
        return ;
    if (px->cmds)
    {
        for (int i = 0; i < px->cmd_count; ++i)
        {
            px_free_split(px->cmds[i].argv);
            free(px->cmds[i].path);
        }
        free(px->cmds);
    }
}
