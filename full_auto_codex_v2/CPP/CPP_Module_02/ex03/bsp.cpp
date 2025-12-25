#include "Point.hpp"

static Fixed cross(Point const &a, Point const &b, Point const &c)
{
	Fixed abx = b.getX() - a.getX();
	Fixed aby = b.getY() - a.getY();
	Fixed acx = c.getX() - a.getX();
	Fixed acy = c.getY() - a.getY();
	return (abx * acy) - (aby * acx);
}

bool bsp(Point const a, Point const b, Point const c, Point const point)
{
	Fixed c1 = cross(a, b, point);
	Fixed c2 = cross(b, c, point);
	Fixed c3 = cross(c, a, point);

	bool has_neg = (c1 < Fixed(0)) || (c2 < Fixed(0)) || (c3 < Fixed(0));
	bool has_pos = (c1 > Fixed(0)) || (c2 > Fixed(0)) || (c3 > Fixed(0));

	// point on edge -> consider outside for strict inclusion
	if (c1.getRawBits() == 0 || c2.getRawBits() == 0 || c3.getRawBits() == 0)
		return false;

	return !(has_neg && has_pos);
}
