#include "kalman.hpp"

#include <cassert>
#include <cmath>
#include <iostream>

static bool approx(double a, double b, double eps = 1e-3)
{
	return std::fabs(a - b) < eps;
}

static void test_matrix_inverse()
{
	Matrix<3, 3> m = {
		4.0, 7.0, 2.0,
		3.0, 6.0, 1.0,
		2.0, 5.0, 1.0};
	Matrix<3, 3> inv = inverse3x3(m);
	Matrix<3, 3> prod = m * inv;
	for (std::size_t r = 0; r < 3; ++r)
	{
		for (std::size_t c = 0; c < 3; ++c)
		{
			const double expected = (r == c) ? 1.0 : 0.0;
			assert(approx(prod(r, c), expected, 1e-6));
		}
	}

	Matrix<3, 3> singular;
	bool threw = false;
	try
	{
		(void)inverse3x3(singular);
	}
	catch (const std::runtime_error &)
	{
		threw = true;
	}
	assert(threw);
}

static void test_matrix_transpose()
{
	Matrix<2, 3> m = {1.0, 2.0, 3.0,
					  4.0, 5.0, 6.0};
	Matrix<3, 2> t = transpose(m);
	assert(approx(t(0, 0), 1.0));
	assert(approx(t(0, 1), 4.0));
	assert(approx(t(1, 0), 2.0));
	assert(approx(t(1, 1), 5.0));
	assert(approx(t(2, 0), 3.0));
	assert(approx(t(2, 1), 6.0));
}

static void test_matrix_identity_multiply()
{
	Matrix<2, 2> m = {2.0, -1.0,
					  0.5, 4.0};
	Matrix<2, 2> ident = Matrix<2, 2>::Identity();
	Matrix<2, 2> left = ident * m;
	Matrix<2, 2> right = m * ident;
	for (std::size_t r = 0; r < 2; ++r)
	{
		for (std::size_t c = 0; c < 2; ++c)
		{
			assert(approx(left(r, c), m(r, c), 1e-9));
			assert(approx(right(r, c), m(r, c), 1e-9));
		}
	}
}

static void test_matrix_determinant()
{
	Matrix<3, 3> m = {
		1.0, 2.0, 3.0,
		0.0, 4.0, 5.0,
		1.0, 0.0, 6.0};
	const double det = determinant3x3(m);
	assert(approx(det, 22.0, 1e-9));
}

int main()
{
	KalmanFilter kf;

	test_matrix_inverse();
	test_matrix_transpose();
	test_matrix_identity_multiply();
	test_matrix_determinant();

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
