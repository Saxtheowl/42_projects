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
    px_free_split(px->cmd1);
    px_free_split(px->cmd2);
    free(px->cmd1_path);
    free(px->cmd2_path);
}
