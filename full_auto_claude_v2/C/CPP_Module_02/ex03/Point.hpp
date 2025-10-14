/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Point.hpp                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef POINT_HPP
# define POINT_HPP

# include "Fixed.hpp"

class Point
{
private:
	Fixed const	x;
	Fixed const	y;

public:
	Point();
	Point(const float x, const float y);
	Point(const Point& other);
	Point& operator=(const Point& other);
	~Point();

	Fixed	getX(void) const;
	Fixed	getY(void) const;
};

bool bsp( Point const a, Point const b, Point const c, Point const point);

#endif
