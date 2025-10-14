/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   events.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "fractol.h"
#include <mlx.h>

int	close_window(t_fractol *f)
{
	mlx_destroy_image(f->mlx, f->img);
	mlx_destroy_window(f->mlx, f->win);
	exit(0);
	return (0);
}

static void	zoom(t_fractol *f, int x, int y, double factor)
{
	double	mouse_r;
	double	mouse_i;
	double	size_r;
	double	size_i;

	mouse_r = f->min_r + (double)x / WIDTH * (f->max_r - f->min_r);
	mouse_i = f->min_i + (double)y / HEIGHT * (f->max_i - f->min_i);
	size_r = (f->max_r - f->min_r) * factor;
	size_i = (f->max_i - f->min_i) * factor;
	f->min_r = mouse_r - (mouse_r - f->min_r) * factor;
	f->max_r = f->min_r + size_r;
	f->min_i = mouse_i - (mouse_i - f->min_i) * factor;
	f->max_i = f->min_i + size_i;
}

int	mouse_press(int button, int x, int y, t_fractol *f)
{
	if (button == MOUSE_SCROLL_UP)
		zoom(f, x, y, 0.9);
	else if (button == MOUSE_SCROLL_DOWN)
		zoom(f, x, y, 1.1);
	render_fractal(f);
	mlx_put_image_to_window(f->mlx, f->win, f->img, 0, 0);
	return (0);
}

static void	move_view(t_fractol *f, int direction)
{
	double	shift_r;
	double	shift_i;

	shift_r = (f->max_r - f->min_r) * 0.1;
	shift_i = (f->max_i - f->min_i) * 0.1;
	if (direction == KEY_LEFT)
	{
		f->min_r -= shift_r;
		f->max_r -= shift_r;
	}
	else if (direction == KEY_RIGHT)
	{
		f->min_r += shift_r;
		f->max_r += shift_r;
	}
	else if (direction == KEY_UP)
	{
		f->min_i -= shift_i;
		f->max_i -= shift_i;
	}
	else if (direction == KEY_DOWN)
	{
		f->min_i += shift_i;
		f->max_i += shift_i;
	}
}

int	key_press(int keycode, t_fractol *f)
{
	if (keycode == KEY_ESC)
		close_window(f);
	else if (keycode == KEY_LEFT || keycode == KEY_RIGHT
		|| keycode == KEY_UP || keycode == KEY_DOWN)
		move_view(f, keycode);
	else if (keycode == KEY_PLUS && f->max_iterations < 500)
		f->max_iterations += 10;
	else if (keycode == KEY_MINUS && f->max_iterations > 10)
		f->max_iterations -= 10;
	else if (keycode == KEY_C)
		f->color_shift = (f->color_shift + 20) % 256;
	else
		return (0);
	render_fractal(f);
	mlx_put_image_to_window(f->mlx, f->win, f->img, 0, 0);
	return (0);
}
