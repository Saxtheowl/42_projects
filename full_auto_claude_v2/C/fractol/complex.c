/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   complex.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "fractol.h"

t_complex	complex_add(t_complex a, t_complex b)
{
	t_complex	result;

	result.r = a.r + b.r;
	result.i = a.i + b.i;
	return (result);
}

t_complex	complex_mul(t_complex a, t_complex b)
{
	t_complex	result;

	result.r = a.r * b.r - a.i * b.i;
	result.i = a.r * b.i + a.i * b.r;
	return (result);
}

t_complex	complex_square(t_complex z)
{
	t_complex	result;

	result.r = z.r * z.r - z.i * z.i;
	result.i = 2 * z.r * z.i;
	return (result);
}

double	complex_abs(t_complex z)
{
	return (z.r * z.r + z.i * z.i);
}
