/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Server.hpp"

void signalHandler(int sig)
{
	(void)sig;
	g_running = false;
	std::cout << "\nShutting down server..." << std::endl;
}

int main(int argc, char* argv[])
{
	std::string configFile = "webserv.conf";

	if (argc > 2)
	{
		std::cerr << "Usage: " << argv[0] << " [config_file]" << std::endl;
		return 1;
	}
	if (argc == 2)
		configFile = argv[1];

	signal(SIGINT, signalHandler);
	signal(SIGTERM, signalHandler);
	signal(SIGPIPE, SIG_IGN);

	try
	{
		Server server;

		std::ifstream file(configFile.c_str());
		if (file.is_open())
		{
			file.close();
			server.loadConfig(configFile);
		}
		else
		{
			std::cout << "No config file found, using defaults" << std::endl;
			ServerConfig config;
			config.setPort(8080);
			config.setRoot("./www");
			Location defaultLoc("/");
			defaultLoc.setRoot("./www");
			defaultLoc.addMethod("GET");
			defaultLoc.addMethod("POST");
			defaultLoc.addMethod("DELETE");
			defaultLoc.setAutoindex(true);
			config.addLocation(defaultLoc);
			server.addConfig(config);
		}

		server.run();
	}
	catch (const std::exception& e)
	{
		std::cerr << "Error: " << e.what() << std::endl;
		return 1;
	}

	return 0;
}
