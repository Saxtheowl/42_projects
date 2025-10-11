#include "Point.hpp"

#include <iostream>

static void testPoint(const Point &a, const Point &b, const Point &c, const Point &p)
{
    std::cout << "Point(" << p.getX().toFloat() << ", " << p.getY().toFloat() << ") -> "
              << (bsp(a, b, c, p) ? "inside" : "outside") << std::endl;
}

int main()
{
    Point a(0.0f, 0.0f);
    Point b(10.0f, 0.0f);
    Point c(0.0f, 10.0f);

    testPoint(a, b, c, Point(2.0f, 2.0f));
    testPoint(a, b, c, Point(5.0f, 1.0f));
    testPoint(a, b, c, Point(1.0f, 5.0f));
    testPoint(a, b, c, Point(0.0f, 0.0f));

    return 0;
}
