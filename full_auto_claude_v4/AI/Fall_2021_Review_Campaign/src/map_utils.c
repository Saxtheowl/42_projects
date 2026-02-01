#include "bsq.h"
#include <unistd.h>

t_map *map_create(void)
{
    t_map *map;

    map = malloc(sizeof(t_map));
    if (!map)
        return (NULL);
    map->grid = NULL;
    map->rows = 0;
    map->cols = 0;
    map->config.row_count = 0;
    map->config.empty_char = 0;
    map->config.obstacle_char = 0;
    map->config.full_char = 0;
    return (map);
}

void map_free(t_map *map)
{
    int i;

    if (!map)
        return;
    if (map->grid)
    {
        i = 0;
        while (i < map->rows)
        {
            free(map->grid[i]);
            i++;
        }
        free(map->grid);
    }
    free(map);
}

void map_print(t_map *map)
{
    int     i;
    int     len;
    ssize_t ret;

    if (!map || !map->grid)
        return;
    i = 0;
    while (i < map->rows)
    {
        len = str_len(map->grid[i]);
        ret = write(1, map->grid[i], len);
        ret = write(1, "\n", 1);
        (void)ret;
        i++;
    }
}
