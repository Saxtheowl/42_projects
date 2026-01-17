#include "kalman.hpp"
#include "udp.hpp"

#include <iostream>
#include <sstream>
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

struct InputSample
{
	double dt;
	Accel accel;
	PositionMeasurement meas;
};

static bool parseSample(const std::string &line, InputSample &out)
{
	std::stringstream ss(line);
	double dt = 0.0, ax = 0.0, ay = 0.0, az = 0.0, mx = 0.0, my = 0.0, mz = 0.0;
	if (!(ss >> dt >> ax >> ay >> az >> mx >> my >> mz))
		return false;
	out.dt = dt;
	out.accel = Accel{ax, ay, az};
	out.meas = PositionMeasurement{mx, my, mz};
	return true;
}

static int run_udp_mode(const std::string &host, uint16_t port, int maxSamples)
{
	KalmanFilter kf;
	UdpSocket sock;
	sock.bindLocal(port);
	sock.setRecvTimeout(2000);

	std::cout << "Listening UDP on " << host << ":" << port << " expecting packets: dt ax ay az mx my mz\n";
	int processed = 0;
	while (processed < maxSamples || maxSamples == 0)
	{
		std::string payload;
		std::string senderIp;
		uint16_t senderPort = 0;
		ssize_t n = sock.recvFrom(payload, &senderIp, &senderPort, 1024);
		if (n < 0)
			continue;
		InputSample sample;
		if (!parseSample(payload, sample))
		{
			std::cerr << "Ignored malformed packet from " << senderIp << ":" << senderPort << " -> " << payload << "\n";
			continue;
		}
		kf.predict(sample.dt, sample.accel);
		kf.update(sample.meas);
		++processed;
		const State &st = kf.state();
		std::ostringstream out;
		out << "{\"step\":" << processed << ",\"pos\":[" << st.x(0, 0) << "," << st.x(1, 0) << "," << st.x(2, 0)
			<< "],\"vel\":[" << st.x(3, 0) << "," << st.x(4, 0) << "," << st.x(5, 0) << "]}";
		const std::string response = out.str();
		if (!senderIp.empty())
			sock.sendTo(response, senderIp, senderPort);
		std::cout << "Processed " << processed << " from " << senderIp << ":" << senderPort << " -> " << response << "\n";
	}
	return 0;
}

int main(int argc, char **argv)
{
	if (argc == 4 && std::string(argv[1]) == "--udp")
	{
		const std::string host = "0.0.0.0";
		const uint16_t port = static_cast<uint16_t>(std::stoi(argv[2]));
		const int maxSamples = std::stoi(argv[3]);
		return run_udp_mode(host, port, maxSamples);
	}
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
