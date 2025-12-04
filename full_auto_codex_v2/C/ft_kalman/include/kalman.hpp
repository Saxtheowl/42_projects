#pragma once

#include "matrix.hpp"
#include "state.hpp"

struct Accel
{
	double ax;
	double ay;
	double az;
};

struct PositionMeasurement
{
	double x;
	double y;
	double z;
};

class KalmanFilter
{
public:
	KalmanFilter();

	// Predict state given acceleration input and timestep (seconds).
	void predict(double dt, const Accel &u);
	// Update with GPS-like position measurement.
	void update(const PositionMeasurement &z);

	const State &state() const { return _state; }

private:
	Matrix<6, 6> _F;
	Matrix<6, 3> _B;
	Matrix<3, 6> _H;
	Matrix<6, 6> _Q;
	Matrix<3, 3> _R;
	State _state;

	void rebuildTransition(double dt);
};
