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

#include "fractol.h"

void	put_pixel(t_fractol *f, int x, int y, int color)
{
	char	*dst;

	if (x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT)
	{
		dst = f->addr + (y * f->line_length + x * (f->bits_per_pixel / 8));
		*(unsigned int *)dst = color;
	}
}

int	get_color(int iteration, int max_iter, int shift)
{
	double	t;
	int		r;
	int		g;
	int		b;

	if (iteration == max_iter)
		return (0x000000);
	t = (double)iteration / max_iter;
	r = (int)(9 * (1 - t) * t * t * t * 255);
	g = (int)(15 * (1 - t) * (1 - t) * t * t * 255);
	b = (int)(8.5 * (1 - t) * (1 - t) * (1 - t) * t * 255);
	r = (r + shift) % 256;
	g = (g + shift) % 256;
	b = (b + shift) % 256;
	return ((r << 16) | (g << 8) | b);
}

static int	calculate_iteration(t_fractol *f, t_complex c)
{
	if (f->fractal_type == MANDELBROT)
		return (mandelbrot(c, f->max_iterations));
	else if (f->fractal_type == JULIA)
		return (julia(c, f->julia_c, f->max_iterations));
	else if (f->fractal_type == BURNING_SHIP)
		return (burning_ship(c, f->max_iterations));
	return (0);
}

void	render_fractal(t_fractol *f)
{
	int			x;
	int			y;
	t_complex	c;
	int			iteration;
	int			color;

	y = 0;
	while (y < HEIGHT)
	{
		x = 0;
		while (x < WIDTH)
		{
			c.r = f->min_r + (double)x / WIDTH * (f->max_r - f->min_r);
			c.i = f->min_i + (double)y / HEIGHT * (f->max_i - f->min_i);
			iteration = calculate_iteration(f, c);
			color = get_color(iteration, f->max_iterations, f->color_shift);
			put_pixel(f, x, y, color);
			x++;
		}
		y++;
	}
}
