/* Simple test program to validate map parsing without graphics */

#include "so_long.h"

static int	test_init_game(t_game *game)
{
	game->mlx = NULL;
	game->win = NULL;
	game->collected = 0;
	game->moves = 0;
	game->game_over = 0;
	game->img.img = NULL;
	return (1);
}

static void	print_map_info(t_game *game)
{
	int	y;

	ft_putstr_fd("Map loaded successfully!\n", 1);
	ft_putstr_fd("Map dimensions: ", 1);
	ft_putnbr_fd(game->map.width, 1);
	ft_putstr_fd(" x ", 1);
	ft_putnbr_fd(game->map.height, 1);
	ft_putstr_fd("\n", 1);
	ft_putstr_fd("Collectibles: ", 1);
	ft_putnbr_fd(game->map.collectibles, 1);
	ft_putstr_fd("\n", 1);
	ft_putstr_fd("Player position: (", 1);
	ft_putnbr_fd(game->map.player_x, 1);
	ft_putstr_fd(", ", 1);
	ft_putnbr_fd(game->map.player_y, 1);
	ft_putstr_fd(")\n", 1);
	ft_putstr_fd("Exit position: (", 1);
	ft_putnbr_fd(game->map.exit_x, 1);
	ft_putstr_fd(", ", 1);
	ft_putnbr_fd(game->map.exit_y, 1);
	ft_putstr_fd(")\n\nMap:\n", 1);
	y = 0;
	while (y < game->map.height)
	{
		ft_putstr_fd(game->map.grid[y], 1);
		ft_putstr_fd("\n", 1);
		y++;
	}
}

int	main(int argc, char **argv)
{
	t_game	game;

	if (argc != 2)
	{
		ft_putstr_fd("Usage: ./test_parser <map.ber>\n", 2);
		return (1);
	}
	test_init_game(&game);
	parse_map(argv[1], &game);
	print_map_info(&game);
	free_map(&game.map);
	return (0);
}
