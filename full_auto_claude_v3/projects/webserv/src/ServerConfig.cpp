/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ServerConfig.cpp                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ServerConfig.hpp"

ServerConfig::ServerConfig()
	: _port(DEFAULT_PORT), _host("0.0.0.0"), _serverName("localhost"),
	  _root("./www"), _index("index.html"), _maxBodySize(DEFAULT_MAX_BODY)
{
}

ServerConfig::ServerConfig(const ServerConfig& other) { *this = other; }

ServerConfig& ServerConfig::operator=(const ServerConfig& other)
{
	if (this != &other)
	{
		_port = other._port;
		_host = other._host;
		_serverName = other._serverName;
		_root = other._root;
		_index = other._index;
		_maxBodySize = other._maxBodySize;
		_errorPages = other._errorPages;
		_locations = other._locations;
	}
	return *this;
}

ServerConfig::~ServerConfig() {}

int ServerConfig::getPort() const { return _port; }
std::string ServerConfig::getHost() const { return _host; }
std::string ServerConfig::getServerName() const { return _serverName; }
std::string ServerConfig::getRoot() const { return _root; }
std::string ServerConfig::getIndex() const { return _index; }
size_t ServerConfig::getMaxBodySize() const { return _maxBodySize; }
const std::vector<Location>& ServerConfig::getLocations() const { return _locations; }

std::string ServerConfig::getErrorPage(int code) const
{
	std::map<int, std::string>::const_iterator it = _errorPages.find(code);
	if (it != _errorPages.end())
		return it->second;
	return "";
}

void ServerConfig::setPort(int port) { _port = port; }
void ServerConfig::setHost(const std::string& host) { _host = host; }
void ServerConfig::setServerName(const std::string& name) { _serverName = name; }
void ServerConfig::setRoot(const std::string& root) { _root = root; }
void ServerConfig::setIndex(const std::string& index) { _index = index; }
void ServerConfig::setMaxBodySize(size_t size) { _maxBodySize = size; }
void ServerConfig::setErrorPage(int code, const std::string& path) { _errorPages[code] = path; }
void ServerConfig::addLocation(const Location& location) { _locations.push_back(location); }

const Location* ServerConfig::findLocation(const std::string& uri) const
{
	const Location* best = NULL;
	size_t bestLen = 0;

	for (size_t i = 0; i < _locations.size(); i++)
	{
		const std::string& path = _locations[i].getPath();
		if (uri.compare(0, path.length(), path) == 0)
		{
			if (path.length() > bestLen)
			{
				best = &_locations[i];
				bestLen = path.length();
			}
		}
	}
	return best;
}
