/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Server.cpp                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Server.hpp"

bool g_running = true;

Server::Server(int port, const std::string& password)
	: _port(port), _password(password), _serverFd(-1),
	  _serverName("ft_irc.42.fr"), _running(true)
{
}

Server::~Server()
{
	for (std::map<int, Client*>::iterator it = _clients.begin();
		 it != _clients.end(); ++it)
		delete it->second;
	for (std::map<std::string, Channel*>::iterator it = _channels.begin();
		 it != _channels.end(); ++it)
		delete it->second;
	if (_serverFd >= 0)
		close(_serverFd);
}

void Server::init()
{
	_serverFd = socket(AF_INET, SOCK_STREAM, 0);
	if (_serverFd < 0)
		throw std::runtime_error("Failed to create socket");

	int opt = 1;
	if (setsockopt(_serverFd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0)
		throw std::runtime_error("Failed to set socket options");

	fcntl(_serverFd, F_SETFL, O_NONBLOCK);

	struct sockaddr_in addr;
	std::memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = INADDR_ANY;
	addr.sin_port = htons(_port);

	if (bind(_serverFd, (struct sockaddr*)&addr, sizeof(addr)) < 0)
		throw std::runtime_error("Failed to bind socket");

	if (listen(_serverFd, MAX_CLIENTS) < 0)
		throw std::runtime_error("Failed to listen on socket");

	std::cout << "IRC Server started on port " << _port << std::endl;
}

void Server::run()
{
	fd_set readFds;
	int maxFd;

	while (_running && g_running)
	{
		FD_ZERO(&readFds);
		FD_SET(_serverFd, &readFds);
		maxFd = _serverFd;

		for (std::map<int, Client*>::iterator it = _clients.begin();
			 it != _clients.end(); ++it)
		{
			FD_SET(it->first, &readFds);
			if (it->first > maxFd)
				maxFd = it->first;
		}

		struct timeval tv;
		tv.tv_sec = 1;
		tv.tv_usec = 0;

		int activity = select(maxFd + 1, &readFds, NULL, NULL, &tv);
		if (activity < 0)
		{
			if (errno == EINTR)
				continue;
			break;
		}

		if (FD_ISSET(_serverFd, &readFds))
			handleNewConnection();

		std::vector<Client*> toRemove;
		for (std::map<int, Client*>::iterator it = _clients.begin();
			 it != _clients.end(); ++it)
		{
			if (FD_ISSET(it->first, &readFds))
			{
				char buffer[BUFFER_SIZE];
				int bytesRead = recv(it->first, buffer, sizeof(buffer) - 1, 0);
				if (bytesRead <= 0)
				{
					toRemove.push_back(it->second);
				}
				else
				{
					buffer[bytesRead] = '\0';
					it->second->appendToBuffer(buffer);
					handleClientMessage(it->second);
				}
			}
		}

		for (size_t i = 0; i < toRemove.size(); i++)
			removeClient(toRemove[i]);
	}
}

void Server::stop()
{
	_running = false;
}

void Server::handleNewConnection()
{
	struct sockaddr_in clientAddr;
	socklen_t addrLen = sizeof(clientAddr);
	int clientFd = accept(_serverFd, (struct sockaddr*)&clientAddr, &addrLen);

	if (clientFd < 0)
		return;

	fcntl(clientFd, F_SETFL, O_NONBLOCK);

	std::string hostname = inet_ntoa(clientAddr.sin_addr);
	Client* client = new Client(clientFd, hostname);
	_clients[clientFd] = client;

	std::cout << "New connection from " << hostname << " (fd: " << clientFd << ")" << std::endl;
}

void Server::handleClientMessage(Client* client)
{
	while (client->hasCompleteMessage())
	{
		std::string message = client->extractMessage();
		if (!message.empty())
		{
			std::cout << "Received from " << client->getNickname()
					  << ": " << message << std::endl;
			parseCommand(client, message);
		}
	}
}

void Server::removeClient(Client* client)
{
	std::cout << "Client " << client->getNickname() << " disconnected" << std::endl;

	for (std::map<std::string, Channel*>::iterator it = _channels.begin();
		 it != _channels.end(); ++it)
	{
		if (it->second->isMember(client))
		{
			it->second->broadcast(":" + client->getPrefix() + " QUIT :Connection closed", client);
			it->second->removeMember(client);
		}
	}

	_clients.erase(client->getFd());
	delete client;
}

std::vector<std::string> Server::splitParams(const std::string& str)
{
	std::vector<std::string> params;
	std::istringstream iss(str);
	std::string token;

	while (iss >> token)
	{
		if (token[0] == ':')
		{
			std::string rest;
			std::getline(iss, rest);
			params.push_back(token.substr(1) + rest);
			break;
		}
		params.push_back(token);
	}
	return params;
}

void Server::parseCommand(Client* client, const std::string& message)
{
	if (message.empty())
		return;

	std::vector<std::string> tokens = splitParams(message);
	if (tokens.empty())
		return;

	std::string cmd = tokens[0];
	for (size_t i = 0; i < cmd.length(); i++)
		cmd[i] = std::toupper(cmd[i]);

	std::vector<std::string> params(tokens.begin() + 1, tokens.end());

	if (cmd == "PASS")
		cmdPass(client, params);
	else if (cmd == "NICK")
		cmdNick(client, params);
	else if (cmd == "USER")
		cmdUser(client, params);
	else if (cmd == "PING")
		cmdPing(client, params);
	else if (!client->isRegistered())
		sendError(client, ERR_NOTREGISTERED, "*", "You have not registered");
	else if (cmd == "JOIN")
		cmdJoin(client, params);
	else if (cmd == "PART")
		cmdPart(client, params);
	else if (cmd == "PRIVMSG")
		cmdPrivmsg(client, params);
	else if (cmd == "NOTICE")
		cmdNotice(client, params);
	else if (cmd == "KICK")
		cmdKick(client, params);
	else if (cmd == "INVITE")
		cmdInvite(client, params);
	else if (cmd == "TOPIC")
		cmdTopic(client, params);
	else if (cmd == "MODE")
		cmdMode(client, params);
	else if (cmd == "QUIT")
		cmdQuit(client, params);
	else
		sendError(client, ERR_UNKNOWNCOMMAND, cmd, "Unknown command");
}

void Server::sendReply(Client* client, const std::string& code,
					   const std::string& message)
{
	client->sendMessage(":" + _serverName + " " + code + " " +
						client->getNickname() + " " + message);
}

void Server::sendError(Client* client, const std::string& code,
					   const std::string& target, const std::string& message)
{
	client->sendMessage(":" + _serverName + " " + code + " " +
						client->getNickname() + " " + target + " :" + message);
}

void Server::welcomeClient(Client* client)
{
	sendReply(client, RPL_WELCOME, ":Welcome to the IRC Network " + client->getPrefix());
	sendReply(client, RPL_YOURHOST, ":Your host is " + _serverName);
	sendReply(client, RPL_CREATED, ":This server was created today");
	sendReply(client, RPL_MYINFO, _serverName + " ft_irc 1.0 o itkol");
}

bool Server::isNicknameInUse(const std::string& nickname)
{
	for (std::map<int, Client*>::iterator it = _clients.begin();
		 it != _clients.end(); ++it)
	{
		if (it->second->getNickname() == nickname)
			return true;
	}
	return false;
}

Client* Server::getClientByNickname(const std::string& nickname)
{
	for (std::map<int, Client*>::iterator it = _clients.begin();
		 it != _clients.end(); ++it)
	{
		if (it->second->getNickname() == nickname)
			return it->second;
	}
	return NULL;
}

Channel* Server::getOrCreateChannel(const std::string& name)
{
	std::map<std::string, Channel*>::iterator it = _channels.find(name);
	if (it != _channels.end())
		return it->second;
	Channel* channel = new Channel(name);
	_channels[name] = channel;
	return channel;
}
