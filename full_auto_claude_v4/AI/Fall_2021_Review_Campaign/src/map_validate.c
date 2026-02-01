#include "bsq.h"

static int is_valid_char(char c, t_map_config *config)
{
    return (c == config->empty_char || c == config->obstacle_char);
}

static int validate_row(char *row, int expected_len, t_map_config *config)
{
    int j;

    if (str_len(row) != expected_len)
        return (0);
    j = 0;
    while (row[j])
    {
        if (!is_valid_char(row[j], config))
            return (0);
        j++;
    }
    return (1);
}

int map_validate(t_map *map)
{
    int i;

    if (!map || !map->grid || map->rows <= 0 || map->cols <= 0)
        return (0);
    if (map->rows != map->config.row_count)
        return (0);
    i = 0;
    while (i < map->rows)
    {
        if (!validate_row(map->grid[i], map->cols, &map->config))
            return (0);
        i++;
    }
    return (1);
}
