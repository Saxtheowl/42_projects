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

#include "fractol.h"

void	init_fractol(t_fractol *f, int type)
{
	f->fractal_type = type;
	f->max_iterations = MAX_ITER;
	f->color_shift = 0;
	if (type == MANDELBROT || type == BURNING_SHIP)
	{
		f->min_r = -2.0;
		f->max_r = 1.0;
		f->min_i = -1.5;
		f->max_i = 1.5;
	}
	else if (type == JULIA)
	{
		f->min_r = -2.0;
		f->max_r = 2.0;
		f->min_i = -2.0;
		f->max_i = 2.0;
	}
}

void	init_julia(t_fractol *f, double r, double i)
{
	f->julia_c.r = r;
	f->julia_c.i = i;
}
