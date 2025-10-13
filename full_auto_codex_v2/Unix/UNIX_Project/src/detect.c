#include "ft_strace.h"

#include <elf.h>
#include <fcntl.h>
#include <unistd.h>

int detect_target_binary(const char *path, t_trace_config *cfg)
{
    unsigned char   ident[EI_NIDENT];
    ssize_t         read_bytes;
    int             fd;

    fd = open(path, O_RDONLY);
    if (fd == -1)
        return (-1);
    read_bytes = read(fd, ident, sizeof(ident));
    close(fd);
    if (read_bytes != (ssize_t)sizeof(ident))
        return (-1);
    if (ident[EI_MAG0] != ELFMAG0 || ident[EI_MAG1] != ELFMAG1
        || ident[EI_MAG2] != ELFMAG2 || ident[EI_MAG3] != ELFMAG3)
        return (-1);
    if (ident[EI_CLASS] == ELFCLASS64)
        cfg->is_64bit = 1;
    else if (ident[EI_CLASS] == ELFCLASS32)
        cfg->is_64bit = 0;
    else
        return (-1);
    return (0);
}
