/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Client.cpp                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Client.hpp"

Client::Client(int fd, const std::string& hostname)
	: _fd(fd), _nickname("*"), _hostname(hostname),
	  _authenticated(false), _registered(false), _passOk(false)
{
}

Client::~Client()
{
	if (_fd >= 0)
		close(_fd);
}

int Client::getFd() const { return _fd; }
std::string Client::getNickname() const { return _nickname; }
std::string Client::getUsername() const { return _username; }
std::string Client::getRealname() const { return _realname; }
std::string Client::getHostname() const { return _hostname; }
bool Client::isAuthenticated() const { return _authenticated; }
bool Client::isRegistered() const { return _registered; }
bool Client::isPassOk() const { return _passOk; }

std::string Client::getPrefix() const
{
	return _nickname + "!" + _username + "@" + _hostname;
}

void Client::setNickname(const std::string& nickname) { _nickname = nickname; }
void Client::setUsername(const std::string& username) { _username = username; }
void Client::setRealname(const std::string& realname) { _realname = realname; }
void Client::setAuthenticated(bool auth) { _authenticated = auth; }
void Client::setRegistered(bool reg) { _registered = reg; }
void Client::setPassOk(bool ok) { _passOk = ok; }

void Client::appendToBuffer(const std::string& data)
{
	_buffer += data;
}

std::string Client::getBuffer() const { return _buffer; }

void Client::clearBuffer()
{
	_buffer.clear();
}

bool Client::hasCompleteMessage() const
{
	return _buffer.find("\r\n") != std::string::npos ||
		   _buffer.find("\n") != std::string::npos;
}

std::string Client::extractMessage()
{
	std::string message;
	size_t pos = _buffer.find("\r\n");
	if (pos != std::string::npos)
	{
		message = _buffer.substr(0, pos);
		_buffer.erase(0, pos + 2);
	}
	else
	{
		pos = _buffer.find("\n");
		if (pos != std::string::npos)
		{
			message = _buffer.substr(0, pos);
			_buffer.erase(0, pos + 1);
		}
	}
	return message;
}

void Client::sendMessage(const std::string& message)
{
	std::string msg = message + "\r\n";
	send(_fd, msg.c_str(), msg.length(), 0);
}
