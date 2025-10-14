/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   render.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "so_long.h"
#include <mlx.h>

void	put_pixel(t_img *img, int x, int y, int color)
{
	char	*dst;

	if (x < 0 || x >= img->width || y < 0 || y >= img->height)
		return ;
	dst = img->addr + (y * img->line_length + x * (img->bits_per_pixel / 8));
	*(unsigned int *)dst = color;
}

void	draw_tile(t_game *game, int x, int y, int color)
{
	int	i;
	int	j;
	int	start_x;
	int	start_y;

	start_x = x * TILE_SIZE;
	start_y = y * TILE_SIZE;
	i = 0;
	while (i < TILE_SIZE)
	{
		j = 0;
		while (j < TILE_SIZE)
		{
			put_pixel(&game->img, start_x + j, start_y + i, color);
			j++;
		}
		i++;
	}
}

static void	render_tile(t_game *game, int x, int y, char tile)
{
	if (tile == '1')
		draw_tile(game, x, y, COLOR_WALL);
	else if (tile == '0')
		draw_tile(game, x, y, COLOR_FLOOR);
	else if (tile == 'C')
		draw_tile(game, x, y, COLOR_COLLECTIBLE);
	else if (tile == 'E')
	{
		if (game->collected == game->map.collectibles)
			draw_tile(game, x, y, COLOR_EXIT);
		else
			draw_tile(game, x, y, 0x95A5A6);
	}
	else if (tile == 'P')
		draw_tile(game, x, y, COLOR_PLAYER);
}

void	render_game(t_game *game)
{
	int	x;
	int	y;

	y = 0;
	while (y < game->map.height)
	{
		x = 0;
		while (x < game->map.width)
		{
			if (x == game->map.player_x && y == game->map.player_y)
				render_tile(game, x, y, 'P');
			else
				render_tile(game, x, y, game->map.grid[y][x]);
			x++;
		}
		y++;
	}
	mlx_put_image_to_window(game->mlx, game->win, game->img.img, 0, 0);
}
