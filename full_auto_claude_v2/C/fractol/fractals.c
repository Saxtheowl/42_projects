/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   fractals.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "fractol.h"

int	mandelbrot(t_complex c, int max_iter)
{
	t_complex	z;
	int			i;

	z.r = 0;
	z.i = 0;
	i = 0;
	while (i < max_iter && complex_abs(z) < 4.0)
	{
		z = complex_square(z);
		z = complex_add(z, c);
		i++;
	}
	return (i);
}

int	julia(t_complex z, t_complex c, int max_iter)
{
	int	i;

	i = 0;
	while (i < max_iter && complex_abs(z) < 4.0)
	{
		z = complex_square(z);
		z = complex_add(z, c);
		i++;
	}
	return (i);
}

int	burning_ship(t_complex c, int max_iter)
{
	t_complex	z;
	double		temp;
	int			i;

	z.r = 0;
	z.i = 0;
	i = 0;
	while (i < max_iter && complex_abs(z) < 4.0)
	{
		z.r = fabs(z.r);
		z.i = fabs(z.i);
		temp = z.r * z.r - z.i * z.i + c.r;
		z.i = 2 * z.r * z.i + c.i;
		z.r = temp;
		i++;
	}
	return (i);
}
