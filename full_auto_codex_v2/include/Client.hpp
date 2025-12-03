#pragma once

#include <set>
#include <string>

struct Client
{
	int fd;
	std::string recvBuffer;
	std::string sendBuffer;
	std::string nickname;
	std::string username;
	std::string realname;
	std::string hostname;
	bool passValidated;
	bool registered;
	std::set<std::string> channels;

	Client(int fd = -1, const std::string &host = "localhost")
		: fd(fd),
		  recvBuffer(),
		  sendBuffer(),
		  nickname(),
		  username(),
		  realname(),
		  hostname(host),
		  passValidated(false),
		  registered(false),
		  channels()
	{
	}

	std::string prefix() const
	{
		const std::string nick = nickname.empty() ? "*" : nickname;
		const std::string user = username.empty() ? "unknown" : username;
		const std::string hostName = hostname.empty() ? "localhost" : hostname;
		return nick + "!" + user + "@" + hostName;
	}
};
