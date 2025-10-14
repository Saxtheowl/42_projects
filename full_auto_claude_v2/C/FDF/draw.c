/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   draw.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "fdf.h"

void	put_pixel(t_fdf *fdf, int x, int y, int color)
{
	char	*dst;

	if (x >= 0 && x < WIN_WIDTH && y >= 0 && y < WIN_HEIGHT)
	{
		dst = fdf->addr + (y * fdf->line_length + x * (fdf->bits_per_pixel / 8));
		*(unsigned int *)dst = color;
	}
}

static int	abs_value(int n)
{
	if (n < 0)
		return (-n);
	return (n);
}

static int	get_max(int a, int b)
{
	if (a > b)
		return (a);
	return (b);
}

static int	get_gradient_color(t_point p1, t_point p2, float ratio)
{
	int	r;
	int	g;
	int	b;

	r = ((p1.color >> 16) & 0xFF) * (1 - ratio) + ((p2.color >> 16) & 0xFF) * ratio;
	g = ((p1.color >> 8) & 0xFF) * (1 - ratio) + ((p2.color >> 8) & 0xFF) * ratio;
	b = (p1.color & 0xFF) * (1 - ratio) + (p2.color & 0xFF) * ratio;
	return ((r << 16) | (g << 8) | b);
}

void	draw_line(t_fdf *fdf, t_point p1, t_point p2)
{
	int		dx;
	int		dy;
	int		steps;
	float	x_inc;
	float	y_inc;
	float	x;
	float	y;
	int		i;
	int		color;

	dx = p2.x - p1.x;
	dy = p2.y - p1.y;
	steps = get_max(abs_value(dx), abs_value(dy));
	x_inc = (float)dx / steps;
	y_inc = (float)dy / steps;
	x = p1.x;
	y = p1.y;
	i = 0;
	while (i <= steps)
	{
		color = get_gradient_color(p1, p2, (float)i / steps);
		put_pixel(fdf, (int)x, (int)y, color);
		x += x_inc;
		y += y_inc;
		i++;
	}
}
