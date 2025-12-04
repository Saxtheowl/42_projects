#include "kalman.hpp"

#include <iostream>
#include <vector>

struct Sample
{
	double dt;
	Accel accel;
	PositionMeasurement meas;
};

static void printState(const State &s, const std::string &label)
{
	std::cout << label << " pos=(" << s.x(0, 0) << "," << s.x(1, 0) << "," << s.x(2, 0)
			  << ") vel=(" << s.x(3, 0) << "," << s.x(4, 0) << "," << s.x(5, 0) << ")\n";
}

int main()
{
	KalmanFilter kf;

	// Synthetic scenario: target drifts toward (100, 50, 20) with small accel noise.
	std::vector<Sample> samples;
	for (int i = 0; i < 20; ++i)
	{
		const double dt = 0.1;
		Sample s;
		s.dt = dt;
		s.accel = Accel{0.05, 0.02, 0.01};
		// Simulate noisy GPS around a linearly increasing position
		const double t = (i + 1) * dt;
		s.meas = PositionMeasurement{
			100.0 * (t / 2.0) / 10.0 + 0.5 * ((i % 2 == 0) ? 1 : -1),
			50.0 * (t / 2.0) / 10.0 + 0.3 * ((i % 3 == 0) ? 1 : -1),
			20.0 * (t / 2.0) / 10.0 + 0.2 * ((i % 4 == 0) ? 1 : -1)};
		samples.push_back(s);
	}

	int step = 0;
	for (std::vector<Sample>::const_iterator it = samples.begin(); it != samples.end(); ++it)
	{
		kf.predict(it->dt, it->accel);
		kf.update(it->meas);
		printState(kf.state(), "Step " + std::to_string(++step));
	}
	return 0;
}
