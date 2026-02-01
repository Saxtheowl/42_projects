/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Commands.cpp                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Server.hpp"

void Server::cmdPass(Client* client, const std::vector<std::string>& params)
{
	if (client->isRegistered())
	{
		sendError(client, ERR_ALREADYREGISTERED, "*", "You may not reregister");
		return;
	}
	if (params.empty())
	{
		sendError(client, ERR_NEEDMOREPARAMS, "PASS", "Not enough parameters");
		return;
	}
	if (params[0] == _password)
		client->setPassOk(true);
	else
		sendError(client, ERR_PASSWDMISMATCH, "*", "Password incorrect");
}

void Server::cmdNick(Client* client, const std::vector<std::string>& params)
{
	if (params.empty())
	{
		sendError(client, ERR_NONICKNAMEGIVEN, "*", "No nickname given");
		return;
	}

	std::string nickname = params[0];
	if (nickname.empty() || nickname[0] == '#' || nickname[0] == ':')
	{
		sendError(client, ERR_ERRONEUSNICKNAME, nickname, "Erroneous nickname");
		return;
	}

	for (size_t i = 0; i < nickname.length(); i++)
	{
		if (!std::isalnum(nickname[i]) && nickname[i] != '_' &&
			nickname[i] != '-' && nickname[i] != '[' && nickname[i] != ']')
		{
			sendError(client, ERR_ERRONEUSNICKNAME, nickname, "Erroneous nickname");
			return;
		}
	}

	if (isNicknameInUse(nickname) && getClientByNickname(nickname) != client)
	{
		sendError(client, ERR_NICKNAMEINUSE, nickname, "Nickname is already in use");
		return;
	}

	std::string oldNick = client->getNickname();
	client->setNickname(nickname);

	if (client->isRegistered())
	{
		for (std::map<std::string, Channel*>::iterator it = _channels.begin();
			 it != _channels.end(); ++it)
		{
			if (it->second->isMember(client))
				it->second->broadcast(":" + oldNick + " NICK " + nickname, NULL);
		}
	}
	else if (client->isPassOk() && !client->getUsername().empty())
	{
		client->setRegistered(true);
		welcomeClient(client);
	}
}

void Server::cmdUser(Client* client, const std::vector<std::string>& params)
{
	if (client->isRegistered())
	{
		sendError(client, ERR_ALREADYREGISTERED, "*", "You may not reregister");
		return;
	}
	if (params.size() < 4)
	{
		sendError(client, ERR_NEEDMOREPARAMS, "USER", "Not enough parameters");
		return;
	}

	client->setUsername(params[0]);
	client->setRealname(params[3]);

	if (client->isPassOk() && client->getNickname() != "*")
	{
		client->setRegistered(true);
		welcomeClient(client);
	}
}

void Server::cmdJoin(Client* client, const std::vector<std::string>& params)
{
	if (params.empty())
	{
		sendError(client, ERR_NEEDMOREPARAMS, "JOIN", "Not enough parameters");
		return;
	}

	std::string channelName = params[0];
	std::string key = params.size() > 1 ? params[1] : "";

	if (channelName[0] != '#')
	{
		sendError(client, ERR_NOSUCHCHANNEL, channelName, "No such channel");
		return;
	}

	Channel* channel = getOrCreateChannel(channelName);

	if (channel->isMember(client))
		return;

	if (channel->isInviteOnly() && !channel->isInvited(client))
	{
		sendError(client, ERR_INVITEONLYCHAN, channelName, "Cannot join channel (+i)");
		return;
	}

	if (!channel->getKey().empty() && channel->getKey() != key)
	{
		sendError(client, ERR_BADCHANNELKEY, channelName, "Cannot join channel (+k)");
		return;
	}

	if (channel->getUserLimit() > 0 && channel->getMemberCount() >= channel->getUserLimit())
	{
		sendError(client, ERR_CHANNELISFULL, channelName, "Cannot join channel (+l)");
		return;
	}

	bool isFirst = (channel->getMemberCount() == 0);
	channel->addMember(client);
	if (isFirst)
		channel->addOperator(client);

	channel->broadcast(":" + client->getPrefix() + " JOIN " + channelName, NULL);

	if (!channel->getTopic().empty())
		sendReply(client, RPL_TOPIC, channelName + " :" + channel->getTopic());
	else
		sendReply(client, RPL_NOTOPIC, channelName + " :No topic is set");

	sendReply(client, RPL_NAMREPLY, "= " + channelName + " :" + channel->getMemberList());
	sendReply(client, RPL_ENDOFNAMES, channelName + " :End of /NAMES list");
}

void Server::cmdPart(Client* client, const std::vector<std::string>& params)
{
	if (params.empty())
	{
		sendError(client, ERR_NEEDMOREPARAMS, "PART", "Not enough parameters");
		return;
	}

	std::string channelName = params[0];
	std::string reason = params.size() > 1 ? params[1] : "Leaving";

	std::map<std::string, Channel*>::iterator it = _channels.find(channelName);
	if (it == _channels.end())
	{
		sendError(client, ERR_NOSUCHCHANNEL, channelName, "No such channel");
		return;
	}

	Channel* channel = it->second;
	if (!channel->isMember(client))
	{
		sendError(client, ERR_NOTONCHANNEL, channelName, "You're not on that channel");
		return;
	}

	channel->broadcast(":" + client->getPrefix() + " PART " + channelName + " :" + reason, NULL);
	channel->removeMember(client);

	if (channel->getMemberCount() == 0)
	{
		delete channel;
		_channels.erase(it);
	}
}

void Server::cmdPrivmsg(Client* client, const std::vector<std::string>& params)
{
	if (params.size() < 2)
	{
		sendError(client, ERR_NEEDMOREPARAMS, "PRIVMSG", "Not enough parameters");
		return;
	}

	std::string target = params[0];
	std::string message = params[1];

	if (target[0] == '#')
	{
		std::map<std::string, Channel*>::iterator it = _channels.find(target);
		if (it == _channels.end())
		{
			sendError(client, ERR_NOSUCHCHANNEL, target, "No such channel");
			return;
		}
		if (!it->second->isMember(client))
		{
			sendError(client, ERR_CANNOTSENDTOCHAN, target, "Cannot send to channel");
			return;
		}
		it->second->broadcast(":" + client->getPrefix() + " PRIVMSG " + target + " :" + message, client);
	}
	else
	{
		Client* targetClient = getClientByNickname(target);
		if (!targetClient)
		{
			sendError(client, ERR_NOSUCHNICK, target, "No such nick/channel");
			return;
		}
		targetClient->sendMessage(":" + client->getPrefix() + " PRIVMSG " + target + " :" + message);
	}
}

void Server::cmdNotice(Client* client, const std::vector<std::string>& params)
{
	if (params.size() < 2)
		return;

	std::string target = params[0];
	std::string message = params[1];

	if (target[0] == '#')
	{
		std::map<std::string, Channel*>::iterator it = _channels.find(target);
		if (it == _channels.end() || !it->second->isMember(client))
			return;
		it->second->broadcast(":" + client->getPrefix() + " NOTICE " + target + " :" + message, client);
	}
	else
	{
		Client* targetClient = getClientByNickname(target);
		if (!targetClient)
			return;
		targetClient->sendMessage(":" + client->getPrefix() + " NOTICE " + target + " :" + message);
	}
}

void Server::cmdKick(Client* client, const std::vector<std::string>& params)
{
	if (params.size() < 2)
	{
		sendError(client, ERR_NEEDMOREPARAMS, "KICK", "Not enough parameters");
		return;
	}

	std::string channelName = params[0];
	std::string targetNick = params[1];
	std::string reason = params.size() > 2 ? params[2] : client->getNickname();

	std::map<std::string, Channel*>::iterator it = _channels.find(channelName);
	if (it == _channels.end())
	{
		sendError(client, ERR_NOSUCHCHANNEL, channelName, "No such channel");
		return;
	}

	Channel* channel = it->second;
	if (!channel->isMember(client))
	{
		sendError(client, ERR_NOTONCHANNEL, channelName, "You're not on that channel");
		return;
	}

	if (!channel->isOperator(client))
	{
		sendError(client, ERR_CHANOPRIVSNEEDED, channelName, "You're not channel operator");
		return;
	}

	Client* target = getClientByNickname(targetNick);
	if (!target || !channel->isMember(target))
	{
		sendError(client, ERR_USERNOTINCHANNEL, targetNick + " " + channelName,
				  "They aren't on that channel");
		return;
	}

	channel->broadcast(":" + client->getPrefix() + " KICK " + channelName + " " +
					   targetNick + " :" + reason, NULL);
	channel->removeMember(target);
}

void Server::cmdInvite(Client* client, const std::vector<std::string>& params)
{
	if (params.size() < 2)
	{
		sendError(client, ERR_NEEDMOREPARAMS, "INVITE", "Not enough parameters");
		return;
	}

	std::string targetNick = params[0];
	std::string channelName = params[1];

	Client* target = getClientByNickname(targetNick);
	if (!target)
	{
		sendError(client, ERR_NOSUCHNICK, targetNick, "No such nick/channel");
		return;
	}

	std::map<std::string, Channel*>::iterator it = _channels.find(channelName);
	if (it == _channels.end())
	{
		sendError(client, ERR_NOSUCHCHANNEL, channelName, "No such channel");
		return;
	}

	Channel* channel = it->second;
	if (!channel->isMember(client))
	{
		sendError(client, ERR_NOTONCHANNEL, channelName, "You're not on that channel");
		return;
	}

	if (channel->isInviteOnly() && !channel->isOperator(client))
	{
		sendError(client, ERR_CHANOPRIVSNEEDED, channelName, "You're not channel operator");
		return;
	}

	if (channel->isMember(target))
	{
		sendError(client, ERR_USERONCHANNEL, targetNick + " " + channelName,
				  "is already on channel");
		return;
	}

	channel->addInvited(target);
	sendReply(client, RPL_INVITING, targetNick + " " + channelName);
	target->sendMessage(":" + client->getPrefix() + " INVITE " + targetNick + " " + channelName);
}

void Server::cmdTopic(Client* client, const std::vector<std::string>& params)
{
	if (params.empty())
	{
		sendError(client, ERR_NEEDMOREPARAMS, "TOPIC", "Not enough parameters");
		return;
	}

	std::string channelName = params[0];

	std::map<std::string, Channel*>::iterator it = _channels.find(channelName);
	if (it == _channels.end())
	{
		sendError(client, ERR_NOSUCHCHANNEL, channelName, "No such channel");
		return;
	}

	Channel* channel = it->second;
	if (!channel->isMember(client))
	{
		sendError(client, ERR_NOTONCHANNEL, channelName, "You're not on that channel");
		return;
	}

	if (params.size() == 1)
	{
		if (channel->getTopic().empty())
			sendReply(client, RPL_NOTOPIC, channelName + " :No topic is set");
		else
			sendReply(client, RPL_TOPIC, channelName + " :" + channel->getTopic());
		return;
	}

	if (channel->isTopicRestricted() && !channel->isOperator(client))
	{
		sendError(client, ERR_CHANOPRIVSNEEDED, channelName, "You're not channel operator");
		return;
	}

	channel->setTopic(params[1]);
	channel->broadcast(":" + client->getPrefix() + " TOPIC " + channelName + " :" + params[1], NULL);
}

void Server::cmdMode(Client* client, const std::vector<std::string>& params)
{
	if (params.empty())
	{
		sendError(client, ERR_NEEDMOREPARAMS, "MODE", "Not enough parameters");
		return;
	}

	std::string target = params[0];

	if (target[0] != '#')
		return;

	std::map<std::string, Channel*>::iterator it = _channels.find(target);
	if (it == _channels.end())
	{
		sendError(client, ERR_NOSUCHCHANNEL, target, "No such channel");
		return;
	}

	Channel* channel = it->second;

	if (params.size() == 1)
	{
		sendReply(client, RPL_CHANNELMODEIS, target + " " + channel->getModes());
		return;
	}

	if (!channel->isOperator(client))
	{
		sendError(client, ERR_CHANOPRIVSNEEDED, target, "You're not channel operator");
		return;
	}

	std::string modes = params[1];
	size_t paramIdx = 2;
	bool adding = true;

	for (size_t i = 0; i < modes.length(); i++)
	{
		if (modes[i] == '+')
			adding = true;
		else if (modes[i] == '-')
			adding = false;
		else if (modes[i] == 'i')
			channel->setInviteOnly(adding);
		else if (modes[i] == 't')
			channel->setTopicRestricted(adding);
		else if (modes[i] == 'k')
		{
			if (adding && paramIdx < params.size())
				channel->setKey(params[paramIdx++]);
			else if (!adding)
				channel->setKey("");
		}
		else if (modes[i] == 'o')
		{
			if (paramIdx < params.size())
			{
				Client* targetClient = getClientByNickname(params[paramIdx++]);
				if (targetClient && channel->isMember(targetClient))
				{
					if (adding)
						channel->addOperator(targetClient);
					else
						channel->removeOperator(targetClient);
				}
			}
		}
		else if (modes[i] == 'l')
		{
			if (adding && paramIdx < params.size())
			{
				int limit = std::atoi(params[paramIdx++].c_str());
				channel->setUserLimit(limit > 0 ? limit : 0);
			}
			else if (!adding)
				channel->setUserLimit(0);
		}
	}

	channel->broadcast(":" + client->getPrefix() + " MODE " + target + " " + modes, NULL);
}

void Server::cmdQuit(Client* client, const std::vector<std::string>& params)
{
	std::string reason = params.empty() ? "Leaving" : params[0];

	for (std::map<std::string, Channel*>::iterator it = _channels.begin();
		 it != _channels.end(); ++it)
	{
		if (it->second->isMember(client))
			it->second->broadcast(":" + client->getPrefix() + " QUIT :" + reason, client);
	}

	removeClient(client);
}

void Server::cmdPing(Client* client, const std::vector<std::string>& params)
{
	std::string token = params.empty() ? _serverName : params[0];
	client->sendMessage(":" + _serverName + " PONG " + _serverName + " :" + token);
}
