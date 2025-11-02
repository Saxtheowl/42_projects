#pragma once

#include "Channel.hpp"
#include "Client.hpp"

#include <map>
#include <poll.h>
#include <string>
#include <vector>
#include <sys/socket.h>

class Server
{
public:
	Server(const std::string &port, const std::string &password);
	~Server();

	int run();

private:
	std::string _port;
	std::string _password;
	std::string _serverName;
	int _listenFd;
	std::map<int, Client> _clients;
	std::map<std::string, Channel> _channels;
	std::vector<struct pollfd> _pollFds;

	void initServerSocket();
	void setupPollFds();
	void cleanup();

	void handleNewConnection();
	bool handleClientData(size_t index);
	bool flushClientSendBuffer(size_t index);
	void disconnectClient(int fd, const std::string &reason);

	void processClientBuffer(Client &client);
	void handleCommand(Client &client, const std::string &line);

	void handlePass(Client &client, const std::vector<std::string> &params);
	void handleCap(Client &client, const std::vector<std::string> &params);
	void handleNick(Client &client, const std::vector<std::string> &params);
	void handleUser(Client &client, const std::vector<std::string> &params);
	void handlePing(Client &client, const std::vector<std::string> &params);
	void handleQuit(Client &client, const std::vector<std::string> &params);
	void handleJoin(Client &client, const std::vector<std::string> &params);
	void handlePart(Client &client, const std::vector<std::string> &params);
	void handlePrivmsg(Client &client, const std::vector<std::string> &params, bool notice);
	void handleMode(Client &client, const std::vector<std::string> &params);
	void handleInvite(Client &client, const std::vector<std::string> &params);
	void handleKick(Client &client, const std::vector<std::string> &params);
	void handleTopic(Client &client, const std::vector<std::string> &params);

	void completeRegistration(Client &client);
	bool requireRegistration(Client &client, const std::string &command);

	void sendToClient(Client &client, const std::string &message);
	void broadcastToChannel(const Channel &channel, const std::string &message, int exceptFd);
	void sendNumeric(Client &client, const std::string &code, const std::string &message);

	Client *findClientByNick(const std::string &nick);
	Channel *findChannel(const std::string &name);
	Channel &getOrCreateChannel(const std::string &name);
	bool isNickInUse(const std::string &nick) const;
	void partChannel(Client &client, const std::string &channelName, const std::string &message, bool notifyClient);
	void partAllChannels(Client &client, const std::string &reason);

	std::string resolveHost(const struct sockaddr_storage &addr, socklen_t len) const;
	std::vector<std::string> tokenize(const std::string &line) const;
	std::vector<std::string> splitComma(const std::string &value) const;
	struct pollfd *findPollEntry(int fd);
};
