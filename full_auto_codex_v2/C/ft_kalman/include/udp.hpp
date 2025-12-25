#pragma once

#include <cstdint>
#include <string>
#include <sys/types.h>

// Minimal RAII wrapper around a UDP socket with timeout helpers.
class UdpSocket
{
public:
	UdpSocket();
	~UdpSocket();

	UdpSocket(const UdpSocket &) = delete;
	UdpSocket &operator=(const UdpSocket &) = delete;
	UdpSocket(UdpSocket &&other) noexcept;
	UdpSocket &operator=(UdpSocket &&other) noexcept;

	// Bind the socket to a local port (0 for ephemeral).
	void bindLocal(uint16_t port);

	// Set receive timeout in milliseconds (0 to disable).
	void setRecvTimeout(int milliseconds);

	// Send a payload to host:port.
	ssize_t sendTo(const std::string &payload, const std::string &host, uint16_t port);

	// Receive into `out`. Returns bytes received or -1 on error/timeout.
	ssize_t recvFrom(std::string &out, std::string *senderIp, uint16_t *senderPort, size_t maxLen = 2048);

	int fd() const { return _fd; }

private:
	int _fd;
};
