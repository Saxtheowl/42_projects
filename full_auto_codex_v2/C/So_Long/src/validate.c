#include "so_long.h"

#include <stddef.h>
#include <stdlib.h>
#include <unistd.h>

static int  check_rectangular(const t_map *map)
{
    size_t  y;

    if (map->height == 0 || map->width == 0)
        return (0);
    y = 0;
    while (y < map->height)
    {
        if (sl_strlen(map->grid[y]) != map->width)
            return (0);
        y++;
    }
    return (1);
}

static int  check_walls(const t_map *map)
{
    size_t  x;
    size_t  y;

    y = 0;
    while (y < map->height)
    {
        if (map->grid[y][0] != '1' || map->grid[y][map->width - 1] != '1')
            return (0);
        y++;
    }
    x = 0;
    while (x < map->width)
    {
        if (map->grid[0][x] != '1' || map->grid[map->height - 1][x] != '1')
            return (0);
        x++;
    }
    return (1);
}

static int  check_characters(const t_map *map)
{
    const char  *allowed = "01CEP";
    size_t      y;
    size_t      x;
    int         valid;

    y = 0;
    while (y < map->height)
    {
        x = 0;
        while (x < map->width)
        {
            valid = 0;
            for (size_t i = 0; allowed[i]; ++i)
            {
                if (map->grid[y][x] == allowed[i])
                    valid = 1;
            }
            if (!valid)
                return (0);
            x++;
        }
        y++;
    }
    return (1);
}

static char **copy_grid(const t_map *map)
{
    char    **copy;

    copy = (char **)malloc(sizeof(char *) * (map->height + 1));
    if (!copy)
        return (NULL);
    for (size_t y = 0; y < map->height; ++y)
    {
        copy[y] = sl_strdup(map->grid[y]);
        if (!copy[y])
        {
            while (y > 0)
                free(copy[--y]);
            free(copy);
            return (NULL);
        }
    }
    copy[map->height] = NULL;
    return (copy);
}

static void free_grid(char **grid)
{
    if (!grid)
        return ;
    for (size_t i = 0; grid[i]; ++i)
        free(grid[i]);
    free(grid);
}

static int  enqueue(size_t *queue, size_t *rear, size_t capacity, size_t value)
{
    if (*rear >= capacity)
        return (0);
    queue[(*rear)++] = value;
    return (1);
}

static int  check_reachability(const t_map *map)
{
    char    **grid;
    size_t  capacity;
    size_t  *queue;
    size_t  front;
    size_t  rear;
    size_t  collected;
    int     exit_found;

    grid = copy_grid(map);
    if (!grid)
        return (0);
    capacity = map->width * map->height;
    queue = (size_t *)malloc(sizeof(size_t) * capacity);
    if (!queue)
    {
        free_grid(grid);
        return (0);
    }
    front = 0;
    rear = 0;
    collected = 0;
    exit_found = 0;
    enqueue(queue, &rear, capacity, map->player_y * map->width + map->player_x);
    while (front < rear)
    {
        size_t pos = queue[front++];
        size_t y = pos / map->width;
        size_t x = pos % map->width;
        char c = grid[y][x];
        if (c == '1' || c == 'V')
            continue ;
        if (c == 'C')
            collected++;
        if (c == 'E')
            exit_found = 1;
        grid[y][x] = 'V';
        if (x > 0 && grid[y][x - 1] != 'V' && grid[y][x - 1] != '1')
            enqueue(queue, &rear, capacity, y * map->width + (x - 1));
        if (x + 1 < map->width && grid[y][x + 1] != 'V' && grid[y][x + 1] != '1')
            enqueue(queue, &rear, capacity, y * map->width + (x + 1));
        if (y > 0 && grid[y - 1][x] != 'V' && grid[y - 1][x] != '1')
            enqueue(queue, &rear, capacity, (y - 1) * map->width + x);
        if (y + 1 < map->height && grid[y + 1][x] != 'V' && grid[y + 1][x] != '1')
            enqueue(queue, &rear, capacity, (y + 1) * map->width + x);
    }
    free(queue);
    free_grid(grid);
    return (collected == map->collectibles && exit_found);
}

static void print_number(size_t n)
{
    char    buffer[20];
    int     len;

    len = 0;
    if (n == 0)
        buffer[len++] = '0';
    while (n > 0)
    {
        buffer[len++] = '0' + (n % 10);
        n /= 10;
    }
    while (len-- > 0)
        write(1, &buffer[len], 1);
}

int sl_validate_map(t_map *map)
{
    if (!check_rectangular(map))
        return (0);
    if (!check_walls(map))
        return (0);
    if (!check_characters(map))
        return (0);
    if (map->players != 1 || map->exits == 0 || map->collectibles == 0)
        return (0);
    if (!check_reachability(map))
        return (0);
    return (1);
}

void    sl_print_map_info(const t_map *map)
{
    sl_putstr_fd("Map loaded successfully\n", 1);
    sl_putstr_fd("Dimensions: ", 1);
    print_number(map->width);
    sl_putstr_fd(" x ", 1);
    print_number(map->height);
    sl_putstr_fd("\nCollectibles: ", 1);
    print_number(map->collectibles);
    sl_putstr_fd("\n", 1);
}
