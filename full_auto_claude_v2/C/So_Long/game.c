/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   game.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "so_long.h"
#include <mlx.h>

void	check_collectible(t_game *game)
{
	int	x;
	int	y;

	x = game->map.player_x;
	y = game->map.player_y;
	if (game->map.grid[y][x] == 'C')
	{
		game->map.grid[y][x] = '0';
		game->collected++;
	}
}

void	check_exit(t_game *game)
{
	int	x;
	int	y;

	x = game->map.player_x;
	y = game->map.player_y;
	if (x == game->map.exit_x && y == game->map.exit_y)
	{
		if (game->collected == game->map.collectibles)
		{
			ft_putstr_fd("Congratulations! You won!\n", 1);
			ft_putstr_fd("Total moves: ", 1);
			ft_putnbr_fd(game->moves, 1);
			ft_putstr_fd("\n", 1);
			game->game_over = 1;
			mlx_destroy_window(game->mlx, game->win);
			exit(0);
		}
	}
}

void	move_player(t_game *game, int dx, int dy)
{
	int	new_x;
	int	new_y;

	new_x = game->map.player_x + dx;
	new_y = game->map.player_y + dy;
	if (new_x < 0 || new_x >= game->map.width
		|| new_y < 0 || new_y >= game->map.height)
		return ;
	if (game->map.grid[new_y][new_x] == '1')
		return ;
	game->map.player_x = new_x;
	game->map.player_y = new_y;
	game->moves++;
	ft_putstr_fd("Moves: ", 1);
	ft_putnbr_fd(game->moves, 1);
	ft_putstr_fd("\n", 1);
	check_collectible(game);
	check_exit(game);
	render_game(game);
}
