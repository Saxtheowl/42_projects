#include "kalman.hpp"

#include <cassert>
#include <cmath>
#include <iostream>

static bool approx(double a, double b, double eps = 1e-3)
{
	return std::fabs(a - b) < eps;
}

int main()
{
	KalmanFilter kf;

	Accel a = {1.0, 0.0, 0.0};
	kf.predict(1.0, a);

	PositionMeasurement z1 = {0.4, 0.0, 0.0};
	kf.update(z1);

	const State &s = kf.state();
	assert(s.x(0, 0) > 0.0);
	assert(s.x(3, 0) > 0.0);
	assert(approx(s.x(1, 0), 0.0, 1e-6));
	assert(approx(s.x(2, 0), 0.0, 1e-6));

	// Second predict/update should keep moving along X (within tolerance).
	kf.predict(0.5, a);
	PositionMeasurement z2 = {1.0, 0.0, 0.0};
	kf.update(z2);
	const State &s2 = kf.state();
	assert(s2.x(0, 0) > 0.0);
	assert(s2.x(3, 0) > 0.0);

	std::cout << "All kalman tests passed. Pos=" << s2.x(0, 0) << " Vel=" << s2.x(3, 0) << std::endl;
	return 0;
}
