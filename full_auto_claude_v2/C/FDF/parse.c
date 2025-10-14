/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "fdf.h"

static int	count_width(char *line)
{
	char	**split;
	int		width;
	int		i;

	split = ft_split(line, ' ');
	if (!split)
		return (0);
	width = 0;
	while (split[width])
		width++;
	i = 0;
	while (split[i])
		free(split[i++]);
	free(split);
	return (width);
}

static int	count_height(char *filename)
{
	int		fd;
	int		height;
	char	*line;

	fd = open(filename, O_RDONLY);
	if (fd < 0)
		error_exit("Cannot open file");
	height = 0;
	line = get_next_line(fd);
	while (line)
	{
		height++;
		free(line);
		line = get_next_line(fd);
	}
	close(fd);
	return (height);
}

static int	get_color(char *str)
{
	int		i;
	int		color;
	char	c;

	i = 0;
	while (str[i] && str[i] != ',')
		i++;
	if (!str[i])
		return (0xFFFFFF);
	i += 3;
	color = 0;
	while (str[i])
	{
		c = str[i];
		if (c >= '0' && c <= '9')
			color = color * 16 + (c - '0');
		else if (c >= 'a' && c <= 'f')
			color = color * 16 + (c - 'a' + 10);
		else if (c >= 'A' && c <= 'F')
			color = color * 16 + (c - 'A' + 10);
		i++;
	}
	return (color);
}

static void	fill_points(t_map *map, char *line, int y)
{
	char	**split;
	int		x;

	split = ft_split(line, ' ');
	if (!split)
		error_exit("Memory allocation failed");
	x = 0;
	while (x < map->width && split[x])
	{
		map->points[y][x].x = x;
		map->points[y][x].y = y;
		map->points[y][x].z = ft_atoi(split[x]);
		map->points[y][x].color = get_color(split[x]);
		x++;
	}
	x = 0;
	while (split[x])
		free(split[x++]);
	free(split);
}

static void	read_map(t_map *map, char *filename)
{
	int		fd;
	int		y;
	char	*line;

	fd = open(filename, O_RDONLY);
	if (fd < 0)
		error_exit("Cannot open file");
	y = 0;
	line = get_next_line(fd);
	while (line)
	{
		if (line[ft_strlen(line) - 1] == '\n')
			line[ft_strlen(line) - 1] = '\0';
		fill_points(map, line, y);
		free(line);
		y++;
		line = get_next_line(fd);
	}
	close(fd);
}

t_map	*parse_map(char *filename)
{
	t_map	*map;
	int		fd;
	char	*line;
	int		i;

	map = (t_map *)malloc(sizeof(t_map));
	if (!map)
		error_exit("Memory allocation failed");
	map->height = count_height(filename);
	fd = open(filename, O_RDONLY);
	if (fd < 0)
		error_exit("Cannot open file");
	line = get_next_line(fd);
	if (line[ft_strlen(line) - 1] == '\n')
		line[ft_strlen(line) - 1] = '\0';
	map->width = count_width(line);
	free(line);
	close(fd);
	map->points = (t_point **)malloc(sizeof(t_point *) * map->height);
	if (!map->points)
		error_exit("Memory allocation failed");
	i = 0;
	while (i < map->height)
	{
		map->points[i] = (t_point *)malloc(sizeof(t_point) * map->width);
		if (!map->points[i])
			error_exit("Memory allocation failed");
		i++;
	}
	read_map(map, filename);
	return (map);
}

void	free_map(t_map *map)
{
	int	i;

	if (!map)
		return ;
	if (map->points)
	{
		i = 0;
		while (i < map->height)
		{
			if (map->points[i])
				free(map->points[i]);
			i++;
		}
		free(map->points);
	}
	free(map);
}
