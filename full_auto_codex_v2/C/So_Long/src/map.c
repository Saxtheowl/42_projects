#include "so_long.h"

#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

static char *sl_read_file(const char *path)
{
    int     fd;
    char    buffer[1024 + 1];
    ssize_t bytes;
    char    *content;
    char    *tmp;

    fd = open(path, O_RDONLY);
    if (fd < 0)
        return (NULL);
    content = sl_strdup("");
    if (!content)
    {
        close(fd);
        return (NULL);
    }
    while ((bytes = read(fd, buffer, 1024)) > 0)
    {
        buffer[bytes] = '\0';
        tmp = sl_strjoin(content, buffer);
        free(content);
        if (!tmp)
        {
            close(fd);
            return (NULL);
        }
        content = tmp;
    }
    close(fd);
    if (bytes < 0)
    {
        free(content);
        return (NULL);
    }
    return (content);
}

static void sl_count_elements(t_map *map)
{
    size_t  y;
    size_t  x;

    map->collectibles = 0;
    map->exits = 0;
    map->players = 0;
    map->player_x = 0;
    map->player_y = 0;
    y = 0;
    while (y < map->height)
    {
        x = 0;
        while (x < map->width)
        {
            if (map->grid[y][x] == 'C')
                map->collectibles++;
            else if (map->grid[y][x] == 'E')
                map->exits++;
            else if (map->grid[y][x] == 'P')
            {
                map->players++;
                map->player_x = x;
                map->player_y = y;
                map->grid[y][x] = '0';
            }
            x++;
        }
        y++;
    }
}

static void sl_init_map(t_map *map)
{
    map->grid = NULL;
    map->width = 0;
    map->height = 0;
    map->collectibles = 0;
    map->exits = 0;
    map->players = 0;
    map->player_x = 0;
    map->player_y = 0;
}

int sl_load_map(const char *path, t_map *map)
{
    char    *content;

    sl_init_map(map);
    content = sl_read_file(path);
    if (!content)
        return (-1);
    map->grid = sl_split_lines(content);
    free(content);
    if (!map->grid)
        return (-1);
    while (map->grid[map->height])
        map->height++;
    if (map->height > 0)
        map->width = sl_strlen(map->grid[0]);
    sl_count_elements(map);
    return (0);
}

void    sl_free_map(t_map *map)
{
    sl_free_split(map->grid);
    sl_init_map(map);
}
