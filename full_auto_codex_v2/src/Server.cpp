#include "../include/Server.hpp"

Server::Server(const std::string &port, const std::string &password)
	: _port(port), _password(password)
{
}

Server::~Server()
{
}

int Server::run()
{
	// TODO: implement poll/select loop
	return 0;
}
