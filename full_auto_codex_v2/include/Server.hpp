#pragma once

#include <string>

class Server
{
public:
	Server(const std::string &port, const std::string &password);
	~Server();

	int run();

private:
	std::string _port;
	std::string _password;
};
