/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Channel.hpp                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef CHANNEL_HPP
# define CHANNEL_HPP

# include "irc.hpp"
# include "Client.hpp"

class Channel
{
private:
	std::string				_name;
	std::string				_topic;
	std::string				_key;
	std::set<Client*>		_members;
	std::set<Client*>		_operators;
	std::set<Client*>		_invited;
	bool					_inviteOnly;
	bool					_topicRestricted;
	size_t					_userLimit;

public:
	Channel(const std::string& name);
	~Channel();

	std::string				getName() const;
	std::string				getTopic() const;
	std::string				getKey() const;
	bool					isInviteOnly() const;
	bool					isTopicRestricted() const;
	size_t					getUserLimit() const;
	size_t					getMemberCount() const;

	void					setTopic(const std::string& topic);
	void					setKey(const std::string& key);
	void					setInviteOnly(bool inviteOnly);
	void					setTopicRestricted(bool restricted);
	void					setUserLimit(size_t limit);

	bool					isMember(Client* client) const;
	bool					isOperator(Client* client) const;
	bool					isInvited(Client* client) const;

	void					addMember(Client* client);
	void					removeMember(Client* client);
	void					addOperator(Client* client);
	void					removeOperator(Client* client);
	void					addInvited(Client* client);
	void					removeInvited(Client* client);

	void					broadcast(const std::string& message, Client* exclude);
	std::string				getMemberList() const;
	std::string				getModes() const;
};

#endif
