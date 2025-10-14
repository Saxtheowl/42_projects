/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   bsp.cpp                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Point.hpp"

// Helper function to compute the cross product sign
static Fixed sign(Point const p1, Point const p2, Point const p3)
{
	return ((p1.getX() - p3.getX()) * (p2.getY() - p3.getY()) -
			(p2.getX() - p3.getX()) * (p1.getY() - p3.getY()));
}

bool bsp( Point const a, Point const b, Point const c, Point const point)
{
	Fixed d1, d2, d3;
	bool has_neg, has_pos;

	d1 = sign(point, a, b);
	d2 = sign(point, b, c);
	d3 = sign(point, c, a);

	// If any distance is 0, point is on edge or vertex
	if (d1 == Fixed(0) || d2 == Fixed(0) || d3 == Fixed(0))
		return (false);

	has_neg = (d1 < Fixed(0)) || (d2 < Fixed(0)) || (d3 < Fixed(0));
	has_pos = (d1 > Fixed(0)) || (d2 > Fixed(0)) || (d3 > Fixed(0));

	// Point is inside if all cross products have the same sign
	return (!(has_neg && has_pos));
}
