/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "so_long.h"
#include <mlx.h>

int	init_game(t_game *game)
{
	game->mlx = NULL;
	game->win = NULL;
	game->collected = 0;
	game->moves = 0;
	game->game_over = 0;
	game->img.img = NULL;
	return (1);
}

void	init_mlx(t_game *game)
{
	int	win_width;
	int	win_height;

	game->mlx = mlx_init();
	if (!game->mlx)
		error_exit("Failed to initialize MiniLibX");
	win_width = game->map.width * TILE_SIZE;
	win_height = game->map.height * TILE_SIZE;
	game->win = mlx_new_window(game->mlx, win_width, win_height, "so_long");
	if (!game->win)
		error_exit("Failed to create window");
	game->img.width = win_width;
	game->img.height = win_height;
	game->img.img = mlx_new_image(game->mlx, win_width, win_height);
	if (!game->img.img)
		error_exit("Failed to create image");
	game->img.addr = mlx_get_data_addr(game->img.img,
			&game->img.bits_per_pixel,
			&game->img.line_length,
			&game->img.endian);
}
