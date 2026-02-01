/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Client.hpp                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef CLIENT_HPP
# define CLIENT_HPP

# include "irc.hpp"

class Client
{
private:
	int			_fd;
	std::string	_nickname;
	std::string	_username;
	std::string	_realname;
	std::string	_hostname;
	std::string	_buffer;
	bool		_authenticated;
	bool		_registered;
	bool		_passOk;

public:
	Client(int fd, const std::string& hostname);
	~Client();

	int			getFd() const;
	std::string	getNickname() const;
	std::string	getUsername() const;
	std::string	getRealname() const;
	std::string	getHostname() const;
	std::string	getPrefix() const;
	bool		isAuthenticated() const;
	bool		isRegistered() const;
	bool		isPassOk() const;

	void		setNickname(const std::string& nickname);
	void		setUsername(const std::string& username);
	void		setRealname(const std::string& realname);
	void		setAuthenticated(bool auth);
	void		setRegistered(bool reg);
	void		setPassOk(bool ok);

	void		appendToBuffer(const std::string& data);
	std::string	getBuffer() const;
	void		clearBuffer();
	bool		hasCompleteMessage() const;
	std::string	extractMessage();

	void		sendMessage(const std::string& message);
};

#endif
