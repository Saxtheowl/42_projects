/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   project.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "fdf.h"

t_point	isometric(t_point p, int z_scale)
{
	t_point	result;
	int		x;
	int		y;

	x = p.x;
	y = p.y;
	result.x = (x - y) * cos(0.523599);
	result.y = (x + y) * sin(0.523599) - (p.z * z_scale);
	result.z = p.z;
	result.color = p.color;
	return (result);
}

t_point	project(t_point p, t_fdf *fdf)
{
	t_point	result;

	result = isometric(p, fdf->z_scale);
	result.x = result.x * fdf->zoom + fdf->offset_x;
	result.y = result.y * fdf->zoom + fdf->offset_y;
	result.color = p.color;
	return (result);
}
