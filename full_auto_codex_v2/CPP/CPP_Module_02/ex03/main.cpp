#include "Point.hpp"

#include <iostream>

int main()
{
	Point a(0.0f, 0.0f);
	Point b(10.0f, 0.0f);
	Point c(0.0f, 10.0f);

	Point p1(1.0f, 1.0f);
	Point p2(5.0f, 5.0f);
	Point p3(10.0f, 10.0f);

	std::cout << "p1 inside? " << (bsp(a, b, c, p1) ? "yes" : "no") << std::endl;
	std::cout << "p2 inside? " << (bsp(a, b, c, p2) ? "yes" : "no") << std::endl;
	std::cout << "p3 inside? " << (bsp(a, b, c, p3) ? "yes" : "no") << std::endl;
	return 0;
}
