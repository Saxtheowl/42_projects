/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   map_validation.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "so_long.h"

static void	check_walls(t_game *game)
{
	int	x;
	int	y;

	y = 0;
	while (y < game->map.height)
	{
		x = 0;
		while (x < game->map.width)
		{
			if (y == 0 || y == game->map.height - 1)
			{
				if (game->map.grid[y][x] != '1')
					error_exit("Map must be surrounded by walls");
			}
			else if (x == 0 || x == game->map.width - 1)
			{
				if (game->map.grid[y][x] != '1')
					error_exit("Map must be surrounded by walls");
			}
			x++;
		}
		y++;
	}
}

static void	check_elements(t_game *game)
{
	if (game->map.players != 1)
		error_exit("Map must have exactly 1 player starting position");
	if (game->map.exits != 1)
		error_exit("Map must have exactly 1 exit");
	if (game->map.collectibles < 1)
		error_exit("Map must have at least 1 collectible");
}

int	validate_map(t_game *game)
{
	check_walls(game);
	check_elements(game);
	return (1);
}

void	free_map(t_map *map)
{
	int	i;

	if (!map->grid)
		return ;
	i = 0;
	while (i < map->height)
	{
		if (map->grid[i])
			free(map->grid[i]);
		i++;
	}
	free(map->grid);
}
