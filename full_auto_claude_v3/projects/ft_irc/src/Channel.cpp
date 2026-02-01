/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Channel.cpp                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Channel.hpp"

Channel::Channel(const std::string& name)
	: _name(name), _inviteOnly(false), _topicRestricted(false), _userLimit(0)
{
}

Channel::~Channel()
{
}

std::string Channel::getName() const { return _name; }
std::string Channel::getTopic() const { return _topic; }
std::string Channel::getKey() const { return _key; }
bool Channel::isInviteOnly() const { return _inviteOnly; }
bool Channel::isTopicRestricted() const { return _topicRestricted; }
size_t Channel::getUserLimit() const { return _userLimit; }
size_t Channel::getMemberCount() const { return _members.size(); }

void Channel::setTopic(const std::string& topic) { _topic = topic; }
void Channel::setKey(const std::string& key) { _key = key; }
void Channel::setInviteOnly(bool inviteOnly) { _inviteOnly = inviteOnly; }
void Channel::setTopicRestricted(bool restricted) { _topicRestricted = restricted; }
void Channel::setUserLimit(size_t limit) { _userLimit = limit; }

bool Channel::isMember(Client* client) const
{
	return _members.find(client) != _members.end();
}

bool Channel::isOperator(Client* client) const
{
	return _operators.find(client) != _operators.end();
}

bool Channel::isInvited(Client* client) const
{
	return _invited.find(client) != _invited.end();
}

void Channel::addMember(Client* client)
{
	_members.insert(client);
	_invited.erase(client);
}

void Channel::removeMember(Client* client)
{
	_members.erase(client);
	_operators.erase(client);
}

void Channel::addOperator(Client* client)
{
	_operators.insert(client);
}

void Channel::removeOperator(Client* client)
{
	_operators.erase(client);
}

void Channel::addInvited(Client* client)
{
	_invited.insert(client);
}

void Channel::removeInvited(Client* client)
{
	_invited.erase(client);
}

void Channel::broadcast(const std::string& message, Client* exclude)
{
	for (std::set<Client*>::iterator it = _members.begin();
		 it != _members.end(); ++it)
	{
		if (*it != exclude)
			(*it)->sendMessage(message);
	}
}

std::string Channel::getMemberList() const
{
	std::string list;
	for (std::set<Client*>::const_iterator it = _members.begin();
		 it != _members.end(); ++it)
	{
		if (!list.empty())
			list += " ";
		if (isOperator(*it))
			list += "@";
		list += (*it)->getNickname();
	}
	return list;
}

std::string Channel::getModes() const
{
	std::string modes = "+";
	if (_inviteOnly)
		modes += "i";
	if (_topicRestricted)
		modes += "t";
	if (!_key.empty())
		modes += "k";
	if (_userLimit > 0)
		modes += "l";
	return modes;
}
