/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Server.hpp                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef SERVER_HPP
# define SERVER_HPP

# include "webserv.hpp"
# include "ServerConfig.hpp"
# include "Request.hpp"
# include "Response.hpp"

struct ClientInfo
{
	int			fd;
	Request		request;
	Response	response;
	std::string	responseBuffer;
	size_t		bytesSent;
	ServerConfig*	config;
};

class Server
{
private:
	std::vector<ServerConfig>	_configs;
	std::map<int, int>			_listenFds;
	std::map<int, ClientInfo>	_clients;
	bool						_running;

	void						initSockets();
	void						handleNewConnection(int listenFd);
	void						handleClientRead(int clientFd);
	void						handleClientWrite(int clientFd);
	void						removeClient(int clientFd);

	void						processRequest(ClientInfo& client);
	void						handleGet(ClientInfo& client, const Location* loc);
	void						handlePost(ClientInfo& client, const Location* loc);
	void						handleDelete(ClientInfo& client, const Location* loc);
	void						handleCgi(ClientInfo& client, const Location* loc);

	void						sendError(ClientInfo& client, int code);
	void						sendRedirect(ClientInfo& client, const std::string& url);
	void						serveFile(ClientInfo& client, const std::string& path);
	void						serveDirectory(ClientInfo& client, const std::string& path);

	std::string					getFilePath(const Request& req, const ServerConfig& conf, const Location* loc);
	ServerConfig*				findConfig(int port, const std::string& host);
	static std::string			readFile(const std::string& path);
	static bool					fileExists(const std::string& path);
	static bool					isDirectory(const std::string& path);

public:
	Server();
	~Server();

	void						loadConfig(const std::string& filename);
	void						addConfig(const ServerConfig& config);
	void						run();
	void						stop();
};

#endif
