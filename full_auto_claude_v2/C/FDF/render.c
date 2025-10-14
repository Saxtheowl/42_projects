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

#include "fdf.h"

static void	clear_image(t_fdf *fdf)
{
	int	i;
	int	total_pixels;

	total_pixels = WIN_WIDTH * WIN_HEIGHT;
	i = 0;
	while (i < total_pixels)
	{
		((unsigned int *)fdf->addr)[i] = 0x000000;
		i++;
	}
}

void	render_map(t_fdf *fdf)
{
	int		x;
	int		y;
	t_point	p1;
	t_point	p2;

	clear_image(fdf);
	y = 0;
	while (y < fdf->map->height)
	{
		x = 0;
		while (x < fdf->map->width)
		{
			if (x < fdf->map->width - 1)
			{
				p1 = project(fdf->map->points[y][x], fdf);
				p2 = project(fdf->map->points[y][x + 1], fdf);
				draw_line(fdf, p1, p2);
			}
			if (y < fdf->map->height - 1)
			{
				p1 = project(fdf->map->points[y][x], fdf);
				p2 = project(fdf->map->points[y + 1][x], fdf);
				draw_line(fdf, p1, p2);
			}
			x++;
		}
		y++;
	}
}
