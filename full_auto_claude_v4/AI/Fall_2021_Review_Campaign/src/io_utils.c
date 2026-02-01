#include "bsq.h"
#include <fcntl.h>
#include <unistd.h>

void print_error(void)
{
    ssize_t ret;

    ret = write(2, "map error\n", 10);
    (void)ret;
}

static char *resize_buffer(char *buffer, int *capacity)
{
    char    *new_buffer;
    int     new_capacity;
    int     i;

    new_capacity = (*capacity) * 2;
    new_buffer = malloc(new_capacity);
    if (!new_buffer)
    {
        free(buffer);
        return (NULL);
    }
    i = 0;
    while (i < *capacity)
    {
        new_buffer[i] = buffer[i];
        i++;
    }
    free(buffer);
    *capacity = new_capacity;
    return (new_buffer);
}

static char *read_from_fd(int fd)
{
    char    *buffer;
    char    temp[BUFFER_SIZE];
    int     capacity;
    int     len;
    int     bytes_read;
    int     i;

    capacity = INITIAL_CAPACITY;
    buffer = malloc(capacity);
    if (!buffer)
        return (NULL);
    len = 0;
    while ((bytes_read = read(fd, temp, BUFFER_SIZE)) > 0)
    {
        while (len + bytes_read >= capacity)
        {
            buffer = resize_buffer(buffer, &capacity);
            if (!buffer)
                return (NULL);
        }
        i = 0;
        while (i < bytes_read)
        {
            buffer[len++] = temp[i++];
        }
    }
    if (bytes_read < 0)
    {
        free(buffer);
        return (NULL);
    }
    buffer[len] = '\0';
    return (buffer);
}

char *read_file_content(const char *filename)
{
    int     fd;
    char    *content;

    fd = open(filename, O_RDONLY);
    if (fd < 0)
        return (NULL);
    content = read_from_fd(fd);
    close(fd);
    return (content);
}

char *read_stdin_content(void)
{
    return (read_from_fd(0));
}
