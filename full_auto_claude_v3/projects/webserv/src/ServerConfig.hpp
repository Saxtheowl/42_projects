/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ServerConfig.hpp                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef SERVERCONFIG_HPP
# define SERVERCONFIG_HPP

# include "webserv.hpp"
# include "Location.hpp"

class ServerConfig
{
private:
	int							_port;
	std::string					_host;
	std::string					_serverName;
	std::string					_root;
	std::string					_index;
	size_t						_maxBodySize;
	std::map<int, std::string>	_errorPages;
	std::vector<Location>		_locations;

public:
	ServerConfig();
	ServerConfig(const ServerConfig& other);
	ServerConfig& operator=(const ServerConfig& other);
	~ServerConfig();

	int							getPort() const;
	std::string					getHost() const;
	std::string					getServerName() const;
	std::string					getRoot() const;
	std::string					getIndex() const;
	size_t						getMaxBodySize() const;
	std::string					getErrorPage(int code) const;
	const std::vector<Location>&	getLocations() const;

	void						setPort(int port);
	void						setHost(const std::string& host);
	void						setServerName(const std::string& name);
	void						setRoot(const std::string& root);
	void						setIndex(const std::string& index);
	void						setMaxBodySize(size_t size);
	void						setErrorPage(int code, const std::string& path);
	void						addLocation(const Location& location);

	const Location*				findLocation(const std::string& uri) const;
};

#endif
