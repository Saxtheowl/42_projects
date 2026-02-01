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

# include "irc.hpp"
# include "Client.hpp"
# include "Channel.hpp"

class Server
{
private:
	int							_port;
	std::string					_password;
	int							_serverFd;
	std::string					_serverName;
	std::map<int, Client*>		_clients;
	std::map<std::string, Channel*>	_channels;
	bool						_running;

	void		handleNewConnection();
	void		handleClientMessage(Client* client);
	void		removeClient(Client* client);
	void		parseCommand(Client* client, const std::string& message);

	void		cmdPass(Client* client, const std::vector<std::string>& params);
	void		cmdNick(Client* client, const std::vector<std::string>& params);
	void		cmdUser(Client* client, const std::vector<std::string>& params);
	void		cmdJoin(Client* client, const std::vector<std::string>& params);
	void		cmdPart(Client* client, const std::vector<std::string>& params);
	void		cmdPrivmsg(Client* client, const std::vector<std::string>& params);
	void		cmdNotice(Client* client, const std::vector<std::string>& params);
	void		cmdKick(Client* client, const std::vector<std::string>& params);
	void		cmdInvite(Client* client, const std::vector<std::string>& params);
	void		cmdTopic(Client* client, const std::vector<std::string>& params);
	void		cmdMode(Client* client, const std::vector<std::string>& params);
	void		cmdQuit(Client* client, const std::vector<std::string>& params);
	void		cmdPing(Client* client, const std::vector<std::string>& params);

	void		sendReply(Client* client, const std::string& code,
						const std::string& message);
	void		sendError(Client* client, const std::string& code,
						const std::string& target, const std::string& message);
	void		welcomeClient(Client* client);
	bool		isNicknameInUse(const std::string& nickname);
	Client*		getClientByNickname(const std::string& nickname);
	Channel*	getOrCreateChannel(const std::string& name);

	std::vector<std::string>	splitParams(const std::string& str);

public:
	Server(int port, const std::string& password);
	~Server();

	void		init();
	void		run();
	void		stop();
};

extern bool g_running;

#endif
