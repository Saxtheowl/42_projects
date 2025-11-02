#include "Server.hpp"

#include <cstdlib>
#include <exception>
#include <iostream>
#include <string>

namespace
{
void printUsage(const char *progName)
{
	std::cerr << "Usage: " << progName << " <port> <password>" << std::endl;
}

bool isNumber(const std::string &value)
{
	if (value.empty())
		return false;
	for (std::string::const_iterator it = value.begin(); it != value.end(); ++it)
	{
		if (*it < '0' || *it > '9')
			return false;
	}
	return true;
}
}

int main(int argc, char **argv)
{
	if (argc != 3)
	{
		printUsage(argv[0]);
		return EXIT_FAILURE;
	}

	const std::string port(argv[1]);
	const std::string password(argv[2]);
	if (!isNumber(port))
	{
		std::cerr << "Error: invalid port '" << port << "'" << std::endl;
		return EXIT_FAILURE;
	}
	if (password.empty())
	{
		std::cerr << "Error: password must not be empty" << std::endl;
		return EXIT_FAILURE;
	}

	try
	{
		Server server(port, password);
		return server.run();
	}
	catch (const std::exception &e)
	{
		std::cerr << "Fatal: " << e.what() << std::endl;
	}
	catch (...)
	{
		std::cerr << "Fatal: unknown exception" << std::endl;
	}
	return EXIT_FAILURE;
}
