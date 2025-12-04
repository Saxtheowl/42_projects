#include "kalman.hpp"

#include <cmath>
#include <stdexcept>

KalmanFilter::KalmanFilter()
	: _F(),
	  _B(),
	  _H(),
	  _Q(),
	  _R(),
	  _state()
{
	_state.P = Matrix<6, 6>::Identity() * 10.0; // High initial uncertainty
	// Measurement matrix: observe position components directly.
	_H(0, 0) = 1.0;
	_H(1, 1) = 1.0;
	_H(2, 2) = 1.0;

	// Process noise (tuned empirically for demo).
	_Q = Matrix<6, 6>::Identity() * 0.05;

	// Measurement noise (GPS ~ few meters).
	_R = Matrix<3, 3>::Identity() * 4.0;
}

void KalmanFilter::rebuildTransition(double dt)
{
	_F = Matrix<6, 6>::Identity();
	for (int i = 0; i < 3; ++i)
		_F(i, i + 3) = dt;

	_B = Matrix<6, 3>(); // zero
	for (int axis = 0; axis < 3; ++axis)
	{
		// Position update: 0.5 * a * dt^2
		_B(axis, axis) = 0.5 * dt * dt;
		// Velocity update: a * dt
		_B(axis + 3, axis) = dt;
	}
}

void KalmanFilter::predict(double dt, const Accel &u)
{
	if (dt <= 0.0)
		throw std::runtime_error("dt must be positive");
	rebuildTransition(dt);

	Matrix<3, 1> accel;
	accel(0, 0) = u.ax;
	accel(1, 0) = u.ay;
	accel(2, 0) = u.az;

	_state.x = _F * _state.x + _B * accel;
	Matrix<6, 6> Ft = transpose(_F);
	_state.P = _F * _state.P * Ft + _Q;
}

void KalmanFilter::update(const PositionMeasurement &z)
{
	Matrix<3, 1> meas;
	meas(0, 0) = z.x;
	meas(1, 0) = z.y;
	meas(2, 0) = z.z;

	Matrix<6, 1> x_prior = _state.x;
	Matrix<6, 3> Ht = transpose(_H);

	// Innovation
	Matrix<3, 1> y = meas - _H * x_prior;
	// Innovation covariance
	Matrix<3, 3> S = (_H * _state.P) * Ht + _R;
	Matrix<3, 3> S_inv = inverse3x3(S);
	// Kalman gain
	Matrix<6, 3> K = (_state.P * Ht) * S_inv;
	// State update
	_state.x = x_prior + K * y;
	// Covariance update: P = (I - K H) P
	Matrix<6, 6> I = Matrix<6, 6>::Identity();
	_state.P = (I - K * _H) * _state.P;
}
