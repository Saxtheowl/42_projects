/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Request.cpp                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Request.hpp"

Request::Request()
	: _state(INCOMPLETE), _contentLength(0), _chunked(false)
{
}

Request::Request(const Request& other) { *this = other; }

Request& Request::operator=(const Request& other)
{
	if (this != &other)
	{
		_method = other._method;
		_uri = other._uri;
		_version = other._version;
		_headers = other._headers;
		_body = other._body;
		_query = other._query;
		_state = other._state;
		_contentLength = other._contentLength;
		_chunked = other._chunked;
		_buffer = other._buffer;
	}
	return *this;
}

Request::~Request() {}

void Request::parseRequestLine(const std::string& line)
{
	std::istringstream iss(line);
	iss >> _method >> _uri >> _version;
	if (_method.empty() || _uri.empty() || _version.empty())
	{
		_state = ERROR;
		return;
	}
	parseUri();
}

void Request::parseHeader(const std::string& line)
{
	size_t pos = line.find(':');
	if (pos == std::string::npos)
		return;
	std::string name = line.substr(0, pos);
	std::string value = line.substr(pos + 1);
	while (!value.empty() && (value[0] == ' ' || value[0] == '\t'))
		value.erase(0, 1);
	while (!value.empty() && (value[value.size()-1] == ' ' || value[value.size()-1] == '\t'))
		value.erase(value.size()-1);
	for (size_t i = 0; i < name.length(); i++)
		name[i] = std::tolower(name[i]);
	_headers[name] = value;
}

void Request::parseUri()
{
	size_t pos = _uri.find('?');
	if (pos != std::string::npos)
	{
		_query = _uri.substr(pos + 1);
		_uri = _uri.substr(0, pos);
	}
}

void Request::parse(const std::string& data)
{
	_buffer += data;

	if (_method.empty())
	{
		size_t pos = _buffer.find("\r\n");
		if (pos == std::string::npos)
			return;
		parseRequestLine(_buffer.substr(0, pos));
		_buffer.erase(0, pos + 2);
		if (_state == ERROR)
			return;
	}

	size_t headerEnd = _buffer.find("\r\n\r\n");
	if (headerEnd == std::string::npos && _headers.empty())
		return;

	if (_headers.empty())
	{
		std::string headers = _buffer.substr(0, headerEnd);
		_buffer.erase(0, headerEnd + 4);
		std::istringstream iss(headers);
		std::string line;
		while (std::getline(iss, line))
		{
			if (!line.empty() && line[line.size()-1] == '\r')
				line.erase(line.size()-1);
			if (!line.empty())
				parseHeader(line);
		}
		if (_headers.find("content-length") != _headers.end())
			_contentLength = std::atoi(_headers["content-length"].c_str());
		if (_headers.find("transfer-encoding") != _headers.end() &&
			_headers["transfer-encoding"] == "chunked")
			_chunked = true;
	}

	if (_chunked)
	{
		while (true)
		{
			size_t pos = _buffer.find("\r\n");
			if (pos == std::string::npos)
				break;
			size_t chunkSize = std::strtol(_buffer.substr(0, pos).c_str(), NULL, 16);
			if (chunkSize == 0)
			{
				_state = COMPLETE;
				break;
			}
			if (_buffer.length() < pos + 2 + chunkSize + 2)
				break;
			_body += _buffer.substr(pos + 2, chunkSize);
			_buffer.erase(0, pos + 2 + chunkSize + 2);
		}
	}
	else if (_contentLength > 0)
	{
		if (_buffer.length() >= _contentLength)
		{
			_body = _buffer.substr(0, _contentLength);
			_buffer.erase(0, _contentLength);
			_state = COMPLETE;
		}
	}
	else
	{
		_state = COMPLETE;
	}
}

void Request::clear()
{
	_method.clear();
	_uri.clear();
	_version.clear();
	_headers.clear();
	_body.clear();
	_query.clear();
	_state = INCOMPLETE;
	_contentLength = 0;
	_chunked = false;
	_buffer.clear();
}

std::string Request::getMethod() const { return _method; }
std::string Request::getUri() const { return _uri; }
std::string Request::getVersion() const { return _version; }
std::string Request::getBody() const { return _body; }
std::string Request::getQuery() const { return _query; }
Request::State Request::getState() const { return _state; }
size_t Request::getContentLength() const { return _contentLength; }
bool Request::isComplete() const { return _state == COMPLETE; }
bool Request::hasError() const { return _state == ERROR; }

std::string Request::getHeader(const std::string& name) const
{
	std::string lower = name;
	for (size_t i = 0; i < lower.length(); i++)
		lower[i] = std::tolower(lower[i]);
	std::map<std::string, std::string>::const_iterator it = _headers.find(lower);
	if (it != _headers.end())
		return it->second;
	return "";
}
