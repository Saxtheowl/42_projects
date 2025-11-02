#include "Server.hpp"

#include <algorithm>
#include <arpa/inet.h>
#include <cerrno>
#include <cctype>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <iostream>
#include <netdb.h>
#include <sstream>
#include <stdexcept>
#include <sys/socket.h>
#include <unistd.h>

namespace
{
int toInt(const std::string &str)
{
	char *end = NULL;
	long value = std::strtol(str.c_str(), &end, 10);
	if (end == str.c_str() || *end != '\0' || value < 0 || value > 65535)
		throw std::runtime_error("Invalid port: " + str);
	return static_cast<int>(value);
}

void setNonBlocking(int fd)
{
	int flags = fcntl(fd, F_GETFL, 0);
	if (flags == -1)
		throw std::runtime_error("fcntl(F_GETFL) failed");
	if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) == -1)
		throw std::runtime_error("fcntl(F_SETFL) failed");
}

std::string toUpper(const std::string &value)
{
	std::string copy = value;
	for (size_t i = 0; i < copy.size(); ++i)
		copy[i] = static_cast<char>(std::toupper(copy[i]));
	return copy;
}
}

Server::Server(const std::string &port, const std::string &password)
	: _port(port),
	  _password(password),
	  _serverName("ft_irc"),
	  _listenFd(-1),
	  _clients(),
	  _channels(),
	  _pollFds()
{
}

Server::~Server()
{
	cleanup();
}

void Server::cleanup()
{
	for (std::map<int, Client>::iterator it = _clients.begin(); it != _clients.end(); ++it)
		close(it->first);
	_clients.clear();
	_channels.clear();
	_pollFds.clear();
	if (_listenFd != -1)
	{
		close(_listenFd);
		_listenFd = -1;
	}
}

void Server::initServerSocket()
{
	_listenFd = socket(AF_INET6, SOCK_STREAM, 0);
	if (_listenFd == -1)
		_listenFd = socket(AF_INET, SOCK_STREAM, 0);
	if (_listenFd == -1)
		throw std::runtime_error("socket() failed: " + std::string(std::strerror(errno)));

	int opt = 1;
	if (setsockopt(_listenFd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) == -1)
		throw std::runtime_error("setsockopt() failed");

	setNonBlocking(_listenFd);

	struct sockaddr_in6 addr6;
	std::memset(&addr6, 0, sizeof(addr6));
	addr6.sin6_family = AF_INET6;
	addr6.sin6_addr = in6addr_any;
	addr6.sin6_port = htons(toInt(_port));

	if (bind(_listenFd, reinterpret_cast<struct sockaddr *>(&addr6), sizeof(addr6)) == -1)
	{
		close(_listenFd);
		_listenFd = socket(AF_INET, SOCK_STREAM, 0);
		if (_listenFd == -1)
			throw std::runtime_error("socket() failed: " + std::string(std::strerror(errno)));
		if (setsockopt(_listenFd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) == -1)
			throw std::runtime_error("setsockopt() failed");
		setNonBlocking(_listenFd);

		struct sockaddr_in addr4;
		std::memset(&addr4, 0, sizeof(addr4));
		addr4.sin_family = AF_INET;
		addr4.sin_addr.s_addr = htonl(INADDR_ANY);
		addr4.sin_port = htons(toInt(_port));

		if (bind(_listenFd, reinterpret_cast<struct sockaddr *>(&addr4), sizeof(addr4)) == -1)
			throw std::runtime_error("bind() failed: " + std::string(std::strerror(errno)));
	}

	if (listen(_listenFd, SOMAXCONN) == -1)
		throw std::runtime_error("listen() failed");
}

void Server::setupPollFds()
{
	_pollFds.clear();
	struct pollfd pfd;
	pfd.fd = _listenFd;
	pfd.events = POLLIN;
	pfd.revents = 0;
	_pollFds.push_back(pfd);
}

int Server::run()
{
	initServerSocket();
	setupPollFds();

	while (true)
	{
		int ret = poll(&_pollFds[0], _pollFds.size(), -1);
		if (ret == -1)
		{
			if (errno == EINTR)
				continue;
			throw std::runtime_error("poll() failed");
		}

		if (_pollFds[0].revents & POLLIN)
			handleNewConnection();

		for (size_t i = 1; i < _pollFds.size(); ++i)
		{
			struct pollfd &pfd = _pollFds[i];
			if (pfd.revents & (POLLERR | POLLHUP | POLLNVAL))
			{
				const int fd = pfd.fd;
				disconnectClient(fd, "Connection closed");
				--i;
				continue;
			}
			if (pfd.revents & POLLOUT)
			{
				if (!flushClientSendBuffer(i))
				{
					--i;
					continue;
				}
			}
			if (pfd.revents & POLLIN)
			{
				if (!handleClientData(i))
				{
					--i;
					continue;
				}
			}
		}
	}
	return EXIT_SUCCESS;
}

void Server::handleNewConnection()
{
	struct sockaddr_storage addr;
	socklen_t len = sizeof(addr);
	int fd = accept(_listenFd, reinterpret_cast<struct sockaddr *>(&addr), &len);
	if (fd == -1)
		return;

	try
	{
		setNonBlocking(fd);
		struct pollfd pfd;
		pfd.fd = fd;
		pfd.events = POLLIN;
		pfd.revents = 0;
		_pollFds.push_back(pfd);
		const std::string host = resolveHost(addr, len);
		_clients.insert(std::make_pair(fd, Client(fd, host)));
		std::cout << "Client connected: fd=" << fd << std::endl;
	}
	catch (const std::exception &e)
	{
		std::cerr << "Error accepting client: " << e.what() << std::endl;
		close(fd);
	}
}

bool Server::handleClientData(size_t index)
{
	const int fd = _pollFds[index].fd;
	char buffer[512];
	ssize_t n = recv(fd, buffer, sizeof(buffer), 0);
	if (n == 0)
	{
		disconnectClient(fd, "Client quit");
		return false;
	}
	if (n < 0)
	{
		if (errno == EWOULDBLOCK || errno == EAGAIN)
			return true;
		disconnectClient(fd, "Read error");
		return false;
	}
	Client &client = _clients[fd];
	client.recvBuffer.append(buffer, static_cast<size_t>(n));
	processClientBuffer(client);
	return true;
}

bool Server::flushClientSendBuffer(size_t index)
{
	const int fd = _pollFds[index].fd;
	std::map<int, Client>::iterator it = _clients.find(fd);
	if (it == _clients.end())
		return false;
	Client &client = it->second;
	if (client.sendBuffer.empty())
	{
		_pollFds[index].events &= ~POLLOUT;
		return true;
	}
	ssize_t sent = send(fd, client.sendBuffer.c_str(), client.sendBuffer.size(), 0);
	if (sent < 0)
	{
		if (errno == EWOULDBLOCK || errno == EAGAIN)
			return true;
		disconnectClient(fd, "Write error");
		return false;
	}
	client.sendBuffer.erase(0, static_cast<size_t>(sent));
	if (client.sendBuffer.empty())
		_pollFds[index].events &= ~POLLOUT;
	return true;
}

void Server::disconnectClient(int fd, const std::string &reason)
{
	std::map<int, Client>::iterator it = _clients.find(fd);
	if (it == _clients.end())
		return;

	Client &client = it->second;
	std::cout << "Client disconnected: fd=" << fd << " (" << reason << ")" << std::endl;

	partAllChannels(client, reason);

	for (std::vector<struct pollfd>::iterator itPoll = _pollFds.begin(); itPoll != _pollFds.end(); ++itPoll)
	{
		if (itPoll->fd == fd)
		{
			_pollFds.erase(itPoll);
			break;
		}
	}

	close(fd);
	_clients.erase(it);
}

void Server::processClientBuffer(Client &client)
{
	size_t pos;
	while ((pos = client.recvBuffer.find("\r\n")) != std::string::npos)
	{
		std::string line = client.recvBuffer.substr(0, pos);
		client.recvBuffer.erase(0, pos + 2);
		if (!line.empty() && line[line.size() - 1] == '\r')
			line.erase(line.size() - 1);
		handleCommand(client, line);
	}
}

std::vector<std::string> Server::tokenize(const std::string &line) const
{
	std::vector<std::string> tokens;
	size_t i = 0;
	while (i < line.size())
	{
		if (line[i] == ' ')
		{
			++i;
			continue;
		}
		if (line[i] == ':')
		{
			tokens.push_back(line.substr(i + 1));
			break;
		}
		size_t j = line.find(' ', i);
		if (j == std::string::npos)
		{
			tokens.push_back(line.substr(i));
			break;
		}
		tokens.push_back(line.substr(i, j - i));
		i = j + 1;
	}
	return tokens;
}

std::vector<std::string> Server::splitComma(const std::string &value) const
{
	std::vector<std::string> result;
	size_t start = 0;
	while (start < value.size())
	{
		size_t pos = value.find(',', start);
		if (pos == std::string::npos)
		{
			result.push_back(value.substr(start));
			break;
		}
		result.push_back(value.substr(start, pos - start));
		start = pos + 1;
	}
	if (result.empty())
		result.push_back(value);
	return result;
}

void Server::handleCommand(Client &client, const std::string &line)
{
	if (line.empty())
		return;

	std::vector<std::string> tokens = tokenize(line);
	if (tokens.empty())
		return;

	std::string command = toUpper(tokens[0]);
	tokens.erase(tokens.begin());

	if (command == "PASS")
		handlePass(client, tokens);
	else if (command == "CAP")
		handleCap(client, tokens);
	else if (command == "NICK")
		handleNick(client, tokens);
	else if (command == "USER")
		handleUser(client, tokens);
	else if (command == "PING")
		handlePing(client, tokens);
	else if (command == "PONG")
		(void)tokens;
	else if (command == "QUIT")
		handleQuit(client, tokens);
	else if (command == "JOIN")
	{
		if (requireRegistration(client, command))
			handleJoin(client, tokens);
	}
	else if (command == "PART")
	{
		if (requireRegistration(client, command))
			handlePart(client, tokens);
	}
	else if (command == "PRIVMSG")
	{
		if (requireRegistration(client, command))
			handlePrivmsg(client, tokens, false);
	}
	else if (command == "NOTICE")
	{
		if (requireRegistration(client, command))
			handlePrivmsg(client, tokens, true);
	}
	else if (command == "MODE")
	{
		if (requireRegistration(client, command))
			handleMode(client, tokens);
	}
	else if (command == "INVITE")
	{
		if (requireRegistration(client, command))
			handleInvite(client, tokens);
	}
	else if (command == "KICK")
	{
		if (requireRegistration(client, command))
			handleKick(client, tokens);
	}
	else if (command == "TOPIC")
	{
		if (requireRegistration(client, command))
			handleTopic(client, tokens);
	}
	else
	{
		if (client.registered)
			sendNumeric(client, "421", command + " :Unknown command");
	}
}

bool Server::requireRegistration(Client &client, const std::string &command)
{
	if (client.registered)
		return true;
	sendNumeric(client, "451", command + " :You have not registered");
	return false;
}

void Server::handlePass(Client &client, const std::vector<std::string> &params)
{
	if (params.empty())
	{
		sendNumeric(client, "461", "PASS :Not enough parameters");
		return;
	}
	if (client.registered)
	{
		sendNumeric(client, "462", ":You may not reregister");
		return;
	}
	if (params[0] == _password)
		client.passValidated = true;
	else
		sendNumeric(client, "464", ":Password incorrect");
}

void Server::handleCap(Client &client, const std::vector<std::string> &params)
{
	if (params.empty())
		return;
	const std::string sub = toUpper(params[0]);
	if (sub == "LS")
	{
		sendToClient(client, ":" + _serverName + " CAP * LS :");
	}
	else if (sub == "REQ")
	{
		std::string caps = params.size() > 1 ? params[1] : "";
		sendToClient(client, ":" + _serverName + " CAP * NAK :" + caps);
	}
	else if (sub == "END")
	{
		completeRegistration(client);
	}
}

bool Server::isNickInUse(const std::string &nick) const
{
	for (std::map<int, Client>::const_iterator it = _clients.begin(); it != _clients.end(); ++it)
	{
		if (it->second.nickname == nick)
			return true;
	}
	return false;
}

static bool isValidNickname(const std::string &nick)
{
	if (nick.empty())
		return false;
	const std::string allowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-[]`^{}";
	for (size_t i = 0; i < nick.size(); ++i)
	{
		if (allowed.find(nick[i]) == std::string::npos)
			return false;
	}
	return true;
}

void Server::handleNick(Client &client, const std::vector<std::string> &params)
{
	if (params.empty())
	{
		sendNumeric(client, "431", ":No nickname given");
		return;
}

	const std::string &newNick = params[0];
	if (!isValidNickname(newNick))
	{
		sendNumeric(client, "432", newNick + " :Erroneous nickname");
		return;
	}
	if (isNickInUse(newNick) && client.nickname != newNick)
	{
		sendNumeric(client, "433", newNick + " :Nickname is already in use");
		return;
	}

	const std::string oldPrefix = client.prefix();
	const std::string oldNick = client.nickname;
	client.nickname = newNick;

	if (!oldNick.empty() && client.registered)
	{
		std::string payload = ":" + oldPrefix + " NICK :" + newNick;
		for (std::set<std::string>::const_iterator itChan = client.channels.begin(); itChan != client.channels.end(); ++itChan)
		{
			Channel *channel = findChannel(*itChan);
			if (channel)
				broadcastToChannel(*channel, payload, -1);
		}
		sendToClient(client, payload);
	}

	completeRegistration(client);
}

void Server::handleUser(Client &client, const std::vector<std::string> &params)
{
	if (params.size() < 4)
	{
		sendNumeric(client, "461", "USER :Not enough parameters");
		return;
	}
	if (client.registered)
	{
		sendNumeric(client, "462", ":You may not reregister");
		return;
	}

	client.username = params[0];
	client.realname = params[3];
	completeRegistration(client);
}

void Server::completeRegistration(Client &client)
{
	if (client.registered)
		return;
	if (!client.passValidated || client.nickname.empty() || client.username.empty())
		return;
	client.registered = true;
	sendNumeric(client, "001", ":Welcome to the Internet Relay Network " + client.nickname);
	sendNumeric(client, "002", ":Your host is " + _serverName);
	sendNumeric(client, "003", ":This server was created just now");
	sendNumeric(client, "004", _serverName + " ft_irc 0 0");
}

void Server::handlePing(Client &client, const std::vector<std::string> &params)
{
	const std::string payload = params.empty() ? _serverName : params[0];
	sendToClient(client, ":" + _serverName + " PONG " + _serverName + " :" + payload);
}

void Server::handleQuit(Client &client, const std::vector<std::string> &params)
{
	const std::string reason = params.empty() ? "Client Quit" : params[0];
	disconnectClient(client.fd, reason);
}

void Server::handleJoin(Client &client, const std::vector<std::string> &params)
{
	if (params.empty())
	{
		sendNumeric(client, "461", "JOIN :Not enough parameters");
		return;
	}

	std::vector<std::string> channels = splitComma(params[0]);
	std::vector<std::string> keys = params.size() > 1 ? splitComma(params[1]) : std::vector<std::string>();

	for (size_t idx = 0; idx < channels.size(); ++idx)
	{
		const std::string &name = channels[idx];
		if (name.empty() || (name[0] != '#' && name[0] != '&'))
		{
			sendNumeric(client, "476", name + " :Bad Channel Mask");
			continue;
		}

		Channel &channel = getOrCreateChannel(name);

		if (channel.hasMember(client.fd))
			continue;

		if (!channel.key.empty())
		{
			const std::string providedKey = idx < keys.size() ? keys[idx] : "";
			if (providedKey != channel.key)
			{
				sendNumeric(client, "475", name + " :Cannot join channel (+k)");
				continue;
			}
		}
		else if (channel.members.empty() && idx < keys.size() && !keys[idx].empty())
		{
			channel.key = keys[idx];
		}

		if (channel.userLimit > 0 && channel.members.size() >= channel.userLimit)
		{
			sendNumeric(client, "471", name + " :Channel is full");
			continue;
		}

		if (channel.inviteOnly && channel.invited.find(client.fd) == channel.invited.end())
		{
			sendNumeric(client, "473", name + " :Cannot join channel (+i)");
			continue;
		}

		channel.invited.erase(client.fd);
		channel.members.insert(client.fd);
		client.channels.insert(name);
		if (channel.members.size() == 1)
			channel.operators.insert(client.fd);

		const std::string joinMsg = ":" + client.prefix() + " JOIN " + name;
		broadcastToChannel(channel, joinMsg, -1);

		if (!channel.topic.empty())
			sendNumeric(client, "332", name + " :" + channel.topic);
		else
			sendNumeric(client, "331", name + " :No topic is set");

		std::string names;
		for (std::set<int>::const_iterator itMember = channel.members.begin(); itMember != channel.members.end(); ++itMember)
		{
			const Client &member = _clients.find(*itMember)->second;
			if (!names.empty())
				names += " ";
			if (channel.operators.find(*itMember) != channel.operators.end())
				names += "@";
			names += member.nickname;
		}
		sendNumeric(client, "353", "= " + name + " :" + names);
		sendNumeric(client, "366", name + " :End of /NAMES list.");
	}
}

void Server::partChannel(Client &client, const std::string &channelName, const std::string &message, bool notifyClient)
{
	Channel *channel = findChannel(channelName);
	if (!channel)
	{
		if (notifyClient)
			sendNumeric(client, "403", channelName + " :No such channel");
		return;
	}
	if (!channel->hasMember(client.fd))
	{
		if (notifyClient)
			sendNumeric(client, "442", channelName + " :You're not on that channel");
		return;
	}

	const std::string partMsg = ":" + client.prefix() + " PART " + channelName + (message.empty() ? "" : " :" + message);
	broadcastToChannel(*channel, partMsg, -1);

	client.channels.erase(channelName);
	channel->members.erase(client.fd);
	channel->operators.erase(client.fd);
	channel->invited.erase(client.fd);

	if (channel->members.empty())
	{
		_channels.erase(channel->name);
	}
	else if (channel->operators.empty())
	{
		int newOpFd = *channel->members.begin();
		channel->operators.insert(newOpFd);
		Client &newOp = _clients[newOpFd];
		broadcastToChannel(*channel,
						   ":" + _serverName + " MODE " + channel->name + " +o " + newOp.nickname,
						   -1);
	}

	if (notifyClient && findClientByNick(client.nickname))
		sendToClient(client, partMsg);
}

void Server::handlePart(Client &client, const std::vector<std::string> &params)
{
	if (params.empty())
	{
		sendNumeric(client, "461", "PART :Not enough parameters");
		return;
	}
	const std::string reason = params.size() > 1 ? params[1] : "";
	std::vector<std::string> channels = splitComma(params[0]);
	for (size_t i = 0; i < channels.size(); ++i)
		partChannel(client, channels[i], reason, false);
}

Client *Server::findClientByNick(const std::string &nick)
{
	for (std::map<int, Client>::iterator it = _clients.begin(); it != _clients.end(); ++it)
	{
		if (it->second.nickname == nick)
			return &it->second;
	}
	return NULL;
}

Channel *Server::findChannel(const std::string &name)
{
	std::map<std::string, Channel>::iterator it = _channels.find(name);
	if (it == _channels.end())
		return NULL;
	return &it->second;
}

Channel &Server::getOrCreateChannel(const std::string &name)
{
	std::map<std::string, Channel>::iterator it = _channels.find(name);
	if (it == _channels.end())
	{
		Channel channel;
		channel.name = name;
		_channels.insert(std::make_pair(name, channel));
		return _channels.find(name)->second;
	}
	return it->second;
}

void Server::handlePrivmsg(Client &client, const std::vector<std::string> &params, bool notice)
{
	if (params.empty())
	{
		if (!notice)
			sendNumeric(client, "411", ":No recipient given (PRIVMSG)");
		return;
	}
	if (params.size() < 2)
	{
		if (!notice)
			sendNumeric(client, "412", ":No text to send");
		return;
	}

	const std::string &target = params[0];
	const std::string &message = params[1];
	const std::string prefix = ":" + client.prefix() + (notice ? " NOTICE " : " PRIVMSG ");

	if (!target.empty() && (target[0] == '#' || target[0] == '&'))
	{
		Channel *channel = findChannel(target);
		if (!channel)
		{
			if (!notice)
				sendNumeric(client, "403", target + " :No such channel");
			return;
		}
		if (!channel->hasMember(client.fd))
		{
			if (!notice)
				sendNumeric(client, "404", target + " :Cannot send to channel");
			return;
		}
		broadcastToChannel(*channel, prefix + target + " :" + message, client.fd);
		return;
	}

	Client *targetClient = findClientByNick(target);
	if (!targetClient)
	{
		if (!notice)
			sendNumeric(client, "401", target + " :No such nick/channel");
		return;
	}
	sendToClient(*targetClient, prefix + target + " :" + message);
}

void Server::handleMode(Client &client, const std::vector<std::string> &params)
{
	if (params.empty())
	{
		sendNumeric(client, "461", "MODE :Not enough parameters");
		return;
	}

	const std::string &target = params[0];
	if (target.empty() || (target[0] != '#' && target[0] != '&'))
	{
		sendNumeric(client, "501", target + " :Unknown MODE target");
		return;
	}

	Channel *channel = findChannel(target);
	if (!channel)
	{
		sendNumeric(client, "403", target + " :No such channel");
		return;
	}

	if (params.size() == 1)
	{
		std::string modes = "+";
		std::string paramsOut;
		if (channel->inviteOnly)
			modes += "i";
		if (channel->topicProtected)
			modes += "t";
		if (!channel->key.empty())
		{
			modes += "k";
			paramsOut += " " + channel->key;
		}
		if (channel->userLimit > 0)
		{
			modes += "l";
			std::ostringstream oss;
			oss << channel->userLimit;
			paramsOut += " " + oss.str();
		}
		sendNumeric(client, "324", target + " " + modes + paramsOut);
		return;
	}

	if (!channel->isOperator(client.fd))
	{
		sendNumeric(client, "482", target + " :You're not channel operator");
		return;
	}

	const std::string &modeSequence = params[1];
	size_t paramIdx = 2;
	bool adding = true;
	std::string appliedModes;
	std::vector<std::string> appliedParams;
	char lastSign = 0;

	for (size_t i = 0; i < modeSequence.size(); ++i)
	{
		char flag = modeSequence[i];
		if (flag == '+')
		{
			adding = true;
			continue;
		}
		if (flag == '-')
		{
			adding = false;
			continue;
		}

		switch (flag)
		{
		case 'i':
			if (channel->inviteOnly != adding)
			{
				channel->inviteOnly = adding;
				char sign = adding ? '+' : '-';
				if (lastSign != sign)
				{
					appliedModes += sign;
					lastSign = sign;
				}
				appliedModes += 'i';
			}
			break;
		case 't':
			if (channel->topicProtected != adding)
			{
				channel->topicProtected = adding;
				char sign = adding ? '+' : '-';
				if (lastSign != sign)
				{
					appliedModes += sign;
					lastSign = sign;
				}
				appliedModes += 't';
			}
			break;
		case 'k':
		{
			if (adding)
			{
				if (paramIdx >= params.size())
				{
					sendNumeric(client, "461", "MODE :Not enough parameters");
					return;
				}
				channel->key = params[paramIdx++];
				char sign = '+';
				if (lastSign != sign)
				{
					appliedModes += sign;
					lastSign = sign;
				}
				appliedModes += 'k';
				appliedParams.push_back(channel->key);
			}
			else
			{
				if (!channel->key.empty())
				{
					if (paramIdx < params.size())
						++paramIdx;
					channel->key.clear();
					char sign = '-';
					if (lastSign != sign)
					{
						appliedModes += sign;
						lastSign = sign;
					}
					appliedModes += 'k';
				}
			}
			break;
		}
		case 'l':
			if (adding)
			{
				if (paramIdx >= params.size())
				{
					sendNumeric(client, "461", "MODE :Not enough parameters");
					return;
				}
				char *end = NULL;
				long limit = std::strtol(params[paramIdx].c_str(), &end, 10);
				if (end == params[paramIdx].c_str() || limit <= 0)
				{
					sendNumeric(client, "461", "MODE :Invalid limit");
					return;
				}
				++paramIdx;
				channel->userLimit = static_cast<size_t>(limit);
				char sign = '+';
				if (lastSign != sign)
				{
					appliedModes += sign;
					lastSign = sign;
				}
				appliedModes += 'l';
				std::ostringstream oss;
				oss << channel->userLimit;
				appliedParams.push_back(oss.str());
			}
			else
			{
				if (channel->userLimit != 0)
				{
					channel->userLimit = 0;
					char sign = '-';
					if (lastSign != sign)
					{
						appliedModes += sign;
						lastSign = sign;
					}
					appliedModes += 'l';
				}
			}
			break;
		case 'o':
		{
			if (paramIdx >= params.size())
			{
				sendNumeric(client, "461", "MODE :Not enough parameters");
				return;
			}
			const std::string targetNick = params[paramIdx++];
			Client *targetClient = findClientByNick(targetNick);
			if (!targetClient)
			{
				sendNumeric(client, "401", targetNick + " :No such nick/channel");
				break;
			}
			if (!channel->hasMember(targetClient->fd))
			{
				sendNumeric(client, "441", targetNick + " " + channel->name + " :They aren't on that channel");
				break;
			}
			if (adding)
				channel->operators.insert(targetClient->fd);
			else
				channel->operators.erase(targetClient->fd);
			char sign = adding ? '+' : '-';
			if (lastSign != sign)
			{
				appliedModes += sign;
				lastSign = sign;
			}
			appliedModes += 'o';
			appliedParams.push_back(targetNick);
			break;
		}
		default:
			sendNumeric(client, "472", std::string(1, flag) + " :is unknown mode char to me");
			break;
		}
	}

	if (!appliedModes.empty())
	{
		std::string msg = ":" + client.prefix() + " MODE " + channel->name + " " + appliedModes;
		for (size_t i = 0; i < appliedParams.size(); ++i)
			msg += " " + appliedParams[i];
		broadcastToChannel(*channel, msg, -1);
	}
}

void Server::handleInvite(Client &client, const std::vector<std::string> &params)
{
	if (params.size() < 2)
	{
		sendNumeric(client, "461", "INVITE :Not enough parameters");
		return;
	}

	const std::string &nick = params[0];
	const std::string &channelName = params[1];

	Client *targetClient = findClientByNick(nick);
	if (!targetClient)
	{
		sendNumeric(client, "401", nick + " :No such nick/channel");
		return;
	}

	Channel *channel = findChannel(channelName);
	if (!channel)
	{
		sendNumeric(client, "403", channelName + " :No such channel");
		return;
	}

	if (!channel->hasMember(client.fd))
	{
		sendNumeric(client, "442", channelName + " :You're not on that channel");
		return;
	}

	if (!channel->isOperator(client.fd))
	{
		sendNumeric(client, "482", channelName + " :You're not channel operator");
		return;
	}

	if (channel->hasMember(targetClient->fd))
	{
		sendNumeric(client, "443", nick + " " + channelName + " :is already on channel");
		return;
	}

	channel->invited.insert(targetClient->fd);
	sendNumeric(client, "341", nick + " " + channelName);
	sendToClient(*targetClient, ":" + client.prefix() + " INVITE " + nick + " :" + channelName);
}

void Server::handleKick(Client &client, const std::vector<std::string> &params)
{
	if (params.size() < 2)
	{
		sendNumeric(client, "461", "KICK :Not enough parameters");
		return;
	}

	const std::string &channelName = params[0];
	const std::string &nick = params[1];
	const std::string reason = params.size() > 2 ? params[2] : client.nickname;

	Channel *channel = findChannel(channelName);
	if (!channel)
	{
		sendNumeric(client, "403", channelName + " :No such channel");
		return;
	}

	if (!channel->isOperator(client.fd))
	{
		sendNumeric(client, "482", channelName + " :You're not channel operator");
		return;
	}

	Client *targetClient = findClientByNick(nick);
	if (!targetClient)
	{
		sendNumeric(client, "401", nick + " :No such nick/channel");
		return;
	}

	if (!channel->hasMember(targetClient->fd))
	{
		sendNumeric(client, "441", nick + " " + channelName + " :They aren't on that channel");
		return;
	}

	const std::string kickMsg = ":" + client.prefix() + " KICK " + channelName + " " + nick + " :" + reason;
	broadcastToChannel(*channel, kickMsg, -1);

	targetClient->channels.erase(channelName);
	channel->members.erase(targetClient->fd);
	channel->operators.erase(targetClient->fd);
	channel->invited.erase(targetClient->fd);

	if (channel->members.empty())
	{
		_channels.erase(channel->name);
	}
	else if (channel->operators.empty())
	{
		int newOpFd = *channel->members.begin();
		channel->operators.insert(newOpFd);
		Client &newOp = _clients[newOpFd];
		broadcastToChannel(*channel,
						   ":" + _serverName + " MODE " + channel->name + " +o " + newOp.nickname,
						   -1);
	}
}

void Server::handleTopic(Client &client, const std::vector<std::string> &params)
{
	if (params.empty())
	{
		sendNumeric(client, "461", "TOPIC :Not enough parameters");
		return;
	}

	const std::string &channelName = params[0];
	Channel *channel = findChannel(channelName);
	if (!channel)
	{
		sendNumeric(client, "403", channelName + " :No such channel");
		return;
	}

	if (params.size() == 1)
	{
		if (channel->topic.empty())
			sendNumeric(client, "331", channelName + " :No topic is set");
		else
			sendNumeric(client, "332", channelName + " :" + channel->topic);
		return;
	}

	if (channel->topicProtected && !channel->isOperator(client.fd))
	{
		sendNumeric(client, "482", channelName + " :You're not channel operator");
		return;
	}

	channel->topic = params[1];
	const std::string topicMsg = ":" + client.prefix() + " TOPIC " + channelName + " :" + channel->topic;
	broadcastToChannel(*channel, topicMsg, -1);
}

void Server::broadcastToChannel(const Channel &channel, const std::string &message, int exceptFd)
{
	for (std::set<int>::const_iterator it = channel.members.begin(); it != channel.members.end(); ++it)
	{
		if (*it == exceptFd)
			continue;
		std::map<int, Client>::iterator itClient = _clients.find(*it);
		if (itClient != _clients.end())
			sendToClient(itClient->second, message);
	}
}

void Server::sendNumeric(Client &client, const std::string &code, const std::string &message)
{
	const std::string target = client.nickname.empty() ? "*" : client.nickname;
	sendToClient(client, ":" + _serverName + " " + code + " " + target + " " + message);
}

void Server::sendToClient(Client &client, const std::string &message)
{
	client.sendBuffer.append(message);
	client.sendBuffer.append("\r\n");
	struct pollfd *entry = findPollEntry(client.fd);
	if (entry)
		entry->events |= POLLOUT;
}

struct pollfd *Server::findPollEntry(int fd)
{
	for (size_t i = 1; i < _pollFds.size(); ++i)
	{
		if (_pollFds[i].fd == fd)
			return &_pollFds[i];
	}
	return NULL;
}

void Server::partAllChannels(Client &client, const std::string &reason)
{
	std::set<std::string> copy = client.channels;
	for (std::set<std::string>::iterator it = copy.begin(); it != copy.end(); ++it)
	{
		Channel *channel = findChannel(*it);
		if (!channel)
			continue;
		const std::string quitMsg = ":" + client.prefix() + " QUIT :" + reason;
		broadcastToChannel(*channel, quitMsg, client.fd);
		channel->members.erase(client.fd);
		channel->operators.erase(client.fd);
		channel->invited.erase(client.fd);
		if (channel->members.empty())
		{
			_channels.erase(channel->name);
		}
		else if (channel->operators.empty())
		{
			int newOpFd = *channel->members.begin();
			channel->operators.insert(newOpFd);
			Client &newOp = _clients[newOpFd];
			broadcastToChannel(*channel,
							   ":" + _serverName + " MODE " + channel->name + " +o " + newOp.nickname,
							   -1);
		}
	}
	client.channels.clear();
}

std::string Server::resolveHost(const struct sockaddr_storage &addr, socklen_t len) const
{
	char host[NI_MAXHOST];
	if (getnameinfo(reinterpret_cast<const struct sockaddr *>(&addr), len, host, sizeof(host), NULL, 0, NI_NUMERICHOST) == 0)
		return std::string(host);
	return "localhost";
}
