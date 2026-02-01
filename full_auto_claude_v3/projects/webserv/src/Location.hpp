/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Location.hpp                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef LOCATION_HPP
# define LOCATION_HPP

# include "webserv.hpp"

class Location
{
private:
	std::string					_path;
	std::string					_root;
	std::string					_index;
	std::set<std::string>		_methods;
	bool						_autoindex;
	std::string					_redirect;
	std::string					_cgiExtension;
	std::string					_cgiPath;
	std::string					_uploadDir;

public:
	Location();
	Location(const std::string& path);
	Location(const Location& other);
	Location& operator=(const Location& other);
	~Location();

	std::string					getPath() const;
	std::string					getRoot() const;
	std::string					getIndex() const;
	bool						isMethodAllowed(const std::string& method) const;
	bool						isAutoindex() const;
	std::string					getRedirect() const;
	std::string					getCgiExtension() const;
	std::string					getCgiPath() const;
	std::string					getUploadDir() const;

	void						setPath(const std::string& path);
	void						setRoot(const std::string& root);
	void						setIndex(const std::string& index);
	void						addMethod(const std::string& method);
	void						setAutoindex(bool autoindex);
	void						setRedirect(const std::string& redirect);
	void						setCgiExtension(const std::string& ext);
	void						setCgiPath(const std::string& path);
	void						setUploadDir(const std::string& dir);
};

#endif
