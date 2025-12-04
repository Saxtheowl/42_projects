#pragma once

#include "matrix.hpp"

struct State
{
	Matrix<6, 1> x; // [x y z vx vy vz]^T
	Matrix<6, 6> P; // Covariance
};
