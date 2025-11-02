#include "../include/Server.hpp"

#include <cstdlib>
#include <exception>
#include <iostream>

static void print_usage(const char *prog)
{
	std::cerr << "Usage: " << prog << " <port> <password>" << std::endl;
}

int main(int argc, char **argv)
{
	if (argc != 3)
	{
		print_usage(argv[0]);
		return EXIT_FAILURE;
	}

	const std::string port = argv[1];
	const std::string password = argv[2];

	try
	{
		Server server(port, password);
		return server.run();
	}
	catch (const std::exception &e)
	{
		std::cerr << "Unexpected error: " << e.what() << std::endl;
	}
	catch (...)
	{
		std::cerr << "Unknown error" << std::endl;
	}
	return EXIT_FAILURE;
}
