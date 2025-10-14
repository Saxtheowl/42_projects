/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   map_parser.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "so_long.h"

static int	count_lines(char *filename)
{
	int		fd;
	int		count;
	char	*line;

	fd = open(filename, O_RDONLY);
	if (fd < 0)
		error_exit("Failed to open map file");
	count = 0;
	line = get_next_line(fd);
	while (line)
	{
		count++;
		free(line);
		line = get_next_line(fd);
	}
	close(fd);
	return (count);
}

static void	init_map_counts(t_game *game)
{
	game->map.collectibles = 0;
	game->map.exits = 0;
	game->map.players = 0;
	game->map.player_x = 0;
	game->map.player_y = 0;
	game->map.exit_x = 0;
	game->map.exit_y = 0;
}

static void	count_map_elements(t_game *game, int y, int x)
{
	char	c;

	c = game->map.grid[y][x];
	if (c == 'C')
		game->map.collectibles++;
	else if (c == 'E')
	{
		game->map.exits++;
		game->map.exit_x = x;
		game->map.exit_y = y;
	}
	else if (c == 'P')
	{
		game->map.players++;
		game->map.player_x = x;
		game->map.player_y = y;
	}
	else if (c != '0' && c != '1' && c != '\n')
		error_exit("Invalid character in map");
}

static void	parse_map_line(t_game *game, char *line, int y)
{
	int	x;
	int	len;

	len = ft_strlen(line);
	if (line[len - 1] == '\n')
	{
		line[len - 1] = '\0';
		len--;
	}
	if (y == 0)
		game->map.width = len;
	else if (len != game->map.width)
		error_exit("Map is not rectangular");
	game->map.grid[y] = ft_strdup(line);
	if (!game->map.grid[y])
		error_exit("Memory allocation failed");
	x = 0;
	while (x < len)
	{
		count_map_elements(game, y, x);
		x++;
	}
}

int	parse_map(char *filename, t_game *game)
{
	int		fd;
	int		y;
	char	*line;

	game->map.height = count_lines(filename);
	if (game->map.height == 0)
		error_exit("Empty map file");
	game->map.grid = malloc(sizeof(char *) * (game->map.height + 1));
	if (!game->map.grid)
		error_exit("Memory allocation failed");
	init_map_counts(game);
	fd = open(filename, O_RDONLY);
	if (fd < 0)
		error_exit("Failed to open map file");
	y = 0;
	line = get_next_line(fd);
	while (line)
	{
		parse_map_line(game, line, y);
		free(line);
		y++;
		line = get_next_line(fd);
	}
	close(fd);
	game->map.grid[y] = NULL;
	return (validate_map(game));
}
