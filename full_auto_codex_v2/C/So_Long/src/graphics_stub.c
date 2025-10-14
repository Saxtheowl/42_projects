#include "so_long.h"

#include <unistd.h>

int sl_setup_graphics(t_game *game)
{
    game->mlx = NULL;
    game->win = NULL;
    game->tile_size = 0;
    game->steps = 0;
    game->remaining = game->map.collectibles;
    game->finished = 0;
    sl_putstr_fd("Warning: MiniLibX disabled, running in headless mode.\n", 1);
    return (0);
}

void    sl_game_loop(t_game *game)
{
    (void)game;
    sl_putstr_fd("Headless mode: No graphical loop executed.\n", 1);
}

void    sl_destroy_graphics(t_game *game)
{
    (void)game;
}
