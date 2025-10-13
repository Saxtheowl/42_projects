#include "get_next_line.h"

#ifndef BUFFER_SIZE
# define BUFFER_SIZE 42
#endif

typedef struct s_fdnode
{
    int                 fd;
    char                *stash;
    struct s_fdnode     *next;
}               t_fdnode;

static t_fdnode   *get_fd_node(t_fdnode **list, int fd)
{
    t_fdnode *node;

    node = *list;
    while (node)
    {
        if (node->fd == fd)
            return (node);
        node = node->next;
    }
    node = (t_fdnode *)malloc(sizeof(t_fdnode));
    if (!node)
        return (NULL);
    node->fd = fd;
    node->stash = NULL;
    node->next = *list;
    *list = node;
    return (node);
}

static void remove_fd_node(t_fdnode **list, int fd)
{
    t_fdnode *prev = NULL;
    t_fdnode *cur = *list;

    while (cur)
    {
        if (cur->fd == fd)
        {
            if (prev)
                prev->next = cur->next;
            else
                *list = cur->next;
            free(cur->stash);
            free(cur);
            return ;
        }
        prev = cur;
        cur = cur->next;
    }
}

static int  append_buffer(t_fdnode *node, char *buffer, ssize_t bytes)
{
    char    *tmp;
    char    *chunk;

    if (bytes <= 0)
        return ((int)bytes);
    chunk = gnl_substr(buffer, 0, (size_t)bytes);
    if (!chunk)
        return (-1);
    tmp = gnl_strjoin(node->stash, chunk);
    free(chunk);
    if (!tmp)
        return (-1);
    free(node->stash);
    node->stash = tmp;
    return (1);
}

static int  fill_stash(int fd, t_fdnode *node)
{
    char    buffer[BUFFER_SIZE + 1];
    ssize_t bytes;

    while (!gnl_strchr(node->stash, '\n'))
    {
        bytes = read(fd, buffer, BUFFER_SIZE);
        if (bytes <= 0)
            return ((int)bytes);
        buffer[bytes] = '\0';
        if (append_buffer(node, buffer, bytes) == -1)
            return (-1);
    }
    return (1);
}

static char *extract_line(t_fdnode *node)
{
    char    *newline;
    size_t  len;
    char    *line;

    if (!node->stash || !*node->stash)
        return (NULL);
    newline = gnl_strchr(node->stash, '\n');
    if (newline)
        len = (size_t)(newline - node->stash) + 1;
    else
        len = gnl_strlen(node->stash);
    line = gnl_substr(node->stash, 0, len);
    return (line);
}

static void update_stash(t_fdnode *node, size_t consumed)
{
    char *remaining;

    if (!node->stash)
        return ;
    if (consumed >= gnl_strlen(node->stash))
    {
        free(node->stash);
        node->stash = NULL;
        return ;
    }
    remaining = gnl_substr(node->stash, consumed,
            gnl_strlen(node->stash) - consumed);
    free(node->stash);
    node->stash = remaining;
}

char    *get_next_line(int fd)
{
    static t_fdnode    *list = NULL;
    t_fdnode           *node;
    char               *line;
    int                 status;
    size_t              len;

    if (fd < 0 || BUFFER_SIZE <= 0)
        return (NULL);
    node = get_fd_node(&list, fd);
    if (!node)
        return (NULL);
    status = fill_stash(fd, node);
    if (status == -1)
    {
        remove_fd_node(&list, fd);
        return (NULL);
    }
    line = extract_line(node);
    if (!line)
    {
        remove_fd_node(&list, fd);
        return (NULL);
    }
    len = gnl_strlen(line);
    update_stash(node, len);
    if (status <= 0 && (!node->stash || !*node->stash))
        remove_fd_node(&list, fd);
    return (line);
}
