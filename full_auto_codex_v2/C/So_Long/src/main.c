#include "so_long.h"

#include <stdlib.h>
#include <stdio.h>

static void print_usage(void)
{
    sl_putstr_fd("Usage: so_long <map.ber>\n", 2);
}

int main(int argc, char **argv)
{
    t_game  game;

    if (argc != 2)
    {
        print_usage();
        return (EXIT_FAILURE);
    }
    if (sl_load_map(argv[1], &game.map) == -1)
    {
        sl_putstr_fd("Error\nFailed to load map\n", 2);
        return (EXIT_FAILURE);
    }

    if (!sl_validate_map(&game.map))
    {
        sl_putstr_fd("Error\nInvalid map\n", 2);
        sl_free_map(&game.map);
        return (EXIT_FAILURE);
    }
    sl_print_map_info(&game.map);
    if (sl_setup_graphics(&game) == 0)
        sl_game_loop(&game);
    sl_destroy_graphics(&game);
    sl_free_map(&game.map);
    return (EXIT_SUCCESS);
}
