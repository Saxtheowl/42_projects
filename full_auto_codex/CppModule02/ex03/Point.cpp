#include "Point.hpp"

Point::Point()
    : m_x(0), m_y(0)
{
}

Point::Point(float x, float y)
    : m_x(x), m_y(y)
{
}

Point::Point(const Point &other)
    : m_x(other.m_x), m_y(other.m_y)
{
}

Point &Point::operator=(const Point &other)
{
    (void)other;
    return *this;
}

Point::~Point()
{
}

const Fixed &Point::getX() const
{
    return m_x;
}

const Fixed &Point::getY() const
{
    return m_y;
}
