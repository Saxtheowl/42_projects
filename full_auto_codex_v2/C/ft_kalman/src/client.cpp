#include "udp.hpp"

#include <chrono>
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <string>

namespace
{
void usage(const char *prog)
{
	std::cerr << "Usage: " << prog << " <host> <port> [handshake_payload] [max_packets]\n";
	std::cerr << "Example: " << prog << " 127.0.0.1 4242 \"HELLO\" 3\n";
}
} // namespace

int main(int argc, char **argv)
{
	if (argc < 3 || argc > 5)
	{
		usage(argv[0]);
		return 1;
	}

	const std::string host = argv[1];
	const uint16_t port = static_cast<uint16_t>(std::atoi(argv[2]));
	const std::string payload = (argc >= 4) ? argv[3] : "HELLO";
	const int max_packets = (argc == 5) ? std::atoi(argv[4]) : 1;

	try
	{
		UdpSocket sock;
		sock.bindLocal(0);		  // Let OS pick a port for the client
		sock.setRecvTimeout(1000); // 1 second timeout

		const ssize_t sent = sock.sendTo(payload, host, port);
		if (sent < 0)
			throw std::runtime_error("Failed to send handshake payload");
		std::cout << "Sent handshake (" << sent << " bytes): " << payload << std::endl;

		for (int i = 0; i < max_packets; ++i)
		{
			std::string data;
			std::string senderIp;
			uint16_t senderPort = 0;
			const auto start = std::chrono::steady_clock::now();
			const ssize_t received = sock.recvFrom(data, &senderIp, &senderPort);
			const auto end = std::chrono::steady_clock::now();
			const auto elapsed_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();

			if (received < 0)
			{
				std::cout << "[timeout] no packet received within 1s\n";
				break;
			}

			std::cout << "Received (" << received << " bytes) from " << senderIp << ":" << senderPort << " in " << elapsed_ms
					  << " ms\n";
			std::cout << data << std::endl;
		}
	}
	catch (const std::exception &e)
	{
		std::cerr << "kalman_client error: " << e.what() << std::endl;
		return 1;
	}
	return 0;
}
