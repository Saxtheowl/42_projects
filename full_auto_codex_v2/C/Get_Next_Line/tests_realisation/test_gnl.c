#include "get_next_line.h"

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    int     fd;
    char    *line;

    if (argc < 2)
        fd = STDIN_FILENO;
    else
    {
        fd = open(argv[1], O_RDONLY);
        if (fd < 0)
        {
            perror("open");
            return (1);
        }
    }
    while ((line = get_next_line(fd)) != NULL)
    {
        fputs(line, stdout);
        free(line);
    }
    if (argc >= 2)
        close(fd);
    return (0);
}
