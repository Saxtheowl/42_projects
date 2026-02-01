/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Location.cpp                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Location.hpp"

Location::Location() : _autoindex(false)
{
	_methods.insert("GET");
}

Location::Location(const std::string& path)
	: _path(path), _autoindex(false)
{
	_methods.insert("GET");
}

Location::Location(const Location& other) { *this = other; }

Location& Location::operator=(const Location& other)
{
	if (this != &other)
	{
		_path = other._path;
		_root = other._root;
		_index = other._index;
		_methods = other._methods;
		_autoindex = other._autoindex;
		_redirect = other._redirect;
		_cgiExtension = other._cgiExtension;
		_cgiPath = other._cgiPath;
		_uploadDir = other._uploadDir;
	}
	return *this;
}

Location::~Location() {}

std::string Location::getPath() const { return _path; }
std::string Location::getRoot() const { return _root; }
std::string Location::getIndex() const { return _index; }
bool Location::isAutoindex() const { return _autoindex; }
std::string Location::getRedirect() const { return _redirect; }
std::string Location::getCgiExtension() const { return _cgiExtension; }
std::string Location::getCgiPath() const { return _cgiPath; }
std::string Location::getUploadDir() const { return _uploadDir; }

bool Location::isMethodAllowed(const std::string& method) const
{
	return _methods.find(method) != _methods.end();
}

void Location::setPath(const std::string& path) { _path = path; }
void Location::setRoot(const std::string& root) { _root = root; }
void Location::setIndex(const std::string& index) { _index = index; }
void Location::addMethod(const std::string& method) { _methods.insert(method); }
void Location::setAutoindex(bool autoindex) { _autoindex = autoindex; }
void Location::setRedirect(const std::string& redirect) { _redirect = redirect; }
void Location::setCgiExtension(const std::string& ext) { _cgiExtension = ext; }
void Location::setCgiPath(const std::string& path) { _cgiPath = path; }
void Location::setUploadDir(const std::string& dir) { _uploadDir = dir; }
