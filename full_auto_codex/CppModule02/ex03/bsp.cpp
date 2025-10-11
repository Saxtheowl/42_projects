#include "Point.hpp"

static float sign(const Point &p1, const Point &p2, const Point &p3)
{
    const float x1 = p1.getX().toFloat();
    const float y1 = p1.getY().toFloat();
    const float x2 = p2.getX().toFloat();
    const float y2 = p2.getY().toFloat();
    const float x3 = p3.getX().toFloat();
    const float y3 = p3.getY().toFloat();

    return (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3);
}

bool bsp(Point const a, Point const b, Point const c, Point const point)
{
    float d1 = sign(point, a, b);
    float d2 = sign(point, b, c);
    float d3 = sign(point, c, a);

    bool hasNeg = (d1 < 0.f) || (d2 < 0.f) || (d3 < 0.f);
    bool hasPos = (d1 > 0.f) || (d2 > 0.f) || (d3 > 0.f);

    if (d1 == 0.f || d2 == 0.f || d3 == 0.f)
        return false;

    return !(hasNeg && hasPos);
}
