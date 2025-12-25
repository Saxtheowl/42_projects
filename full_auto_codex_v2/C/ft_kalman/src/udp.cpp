#include "udp.hpp"

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdexcept>
#include <string>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>
#include <vector>

namespace
{
sockaddr_in makeAddr(const std::string &host, uint16_t port)
{
	sockaddr_in addr;
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	if (inet_pton(AF_INET, host.c_str(), &addr.sin_addr) != 1)
		throw std::runtime_error("inet_pton failed for host: " + host);
	return addr;
}
} // namespace

UdpSocket::UdpSocket() : _fd(::socket(AF_INET, SOCK_DGRAM, 0))
{
	if (_fd < 0)
		throw std::runtime_error("Failed to create UDP socket");
}

UdpSocket::~UdpSocket()
{
	if (_fd >= 0)
		::close(_fd);
}

UdpSocket::UdpSocket(UdpSocket &&other) noexcept : _fd(other._fd)
{
	other._fd = -1;
}

UdpSocket &UdpSocket::operator=(UdpSocket &&other) noexcept
{
	if (this != &other)
	{
		if (_fd >= 0)
			::close(_fd);
		_fd = other._fd;
		other._fd = -1;
	}
	return *this;
}

void UdpSocket::bindLocal(uint16_t port)
{
	sockaddr_in addr;
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = htons(port);
	if (::bind(_fd, reinterpret_cast<sockaddr *>(&addr), sizeof(addr)) < 0)
		throw std::runtime_error("Failed to bind UDP socket");
}

void UdpSocket::setRecvTimeout(int milliseconds)
{
	timeval tv;
	tv.tv_sec = milliseconds / 1000;
	tv.tv_usec = (milliseconds % 1000) * 1000;
	if (::setsockopt(_fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0)
		throw std::runtime_error("Failed to set SO_RCVTIMEO");
}

ssize_t UdpSocket::sendTo(const std::string &payload, const std::string &host, uint16_t port)
{
	const sockaddr_in addr = makeAddr(host, port);
	return ::sendto(_fd, payload.data(), payload.size(), 0, reinterpret_cast<const sockaddr *>(&addr), sizeof(addr));
}

ssize_t UdpSocket::recvFrom(std::string &out, std::string *senderIp, uint16_t *senderPort, size_t maxLen)
{
	std::vector<char> buffer(maxLen);
	sockaddr_in addr;
	socklen_t addrlen = sizeof(addr);

	const ssize_t received = ::recvfrom(_fd, buffer.data(), buffer.size(), 0, reinterpret_cast<sockaddr *>(&addr), &addrlen);
	if (received < 0)
		return received;

	out.assign(buffer.data(), static_cast<size_t>(received));
	if (senderIp)
	{
		char ip[INET_ADDRSTRLEN];
		if (::inet_ntop(AF_INET, &addr.sin_addr, ip, sizeof(ip)))
			*senderIp = ip;
		else
			senderIp->clear();
	}
	if (senderPort)
		*senderPort = ntohs(addr.sin_port);
	return received;
}
