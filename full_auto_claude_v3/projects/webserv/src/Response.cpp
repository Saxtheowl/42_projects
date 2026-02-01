/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Response.cpp                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Response.hpp"

std::map<int, std::string> Response::_statusTexts;

void Response::initStatusTexts()
{
	if (!_statusTexts.empty())
		return;
	_statusTexts[200] = "OK";
	_statusTexts[201] = "Created";
	_statusTexts[204] = "No Content";
	_statusTexts[301] = "Moved Permanently";
	_statusTexts[302] = "Found";
	_statusTexts[304] = "Not Modified";
	_statusTexts[400] = "Bad Request";
	_statusTexts[403] = "Forbidden";
	_statusTexts[404] = "Not Found";
	_statusTexts[405] = "Method Not Allowed";
	_statusTexts[413] = "Payload Too Large";
	_statusTexts[500] = "Internal Server Error";
	_statusTexts[501] = "Not Implemented";
	_statusTexts[502] = "Bad Gateway";
	_statusTexts[503] = "Service Unavailable";
	_statusTexts[504] = "Gateway Timeout";
}

Response::Response() : _statusCode(200)
{
	initStatusTexts();
	_statusText = "OK";
}

Response::Response(const Response& other) { *this = other; }

Response& Response::operator=(const Response& other)
{
	if (this != &other)
	{
		_statusCode = other._statusCode;
		_statusText = other._statusText;
		_headers = other._headers;
		_body = other._body;
	}
	return *this;
}

Response::~Response() {}

void Response::setStatus(int code)
{
	_statusCode = code;
	_statusText = getStatusText(code);
}

void Response::setStatus(int code, const std::string& text)
{
	_statusCode = code;
	_statusText = text;
}

void Response::setHeader(const std::string& name, const std::string& value)
{
	_headers[name] = value;
}

void Response::setBody(const std::string& body)
{
	_body = body;
	std::ostringstream oss;
	oss << body.length();
	setHeader("Content-Length", oss.str());
}

void Response::setContentType(const std::string& type)
{
	setHeader("Content-Type", type);
}

int Response::getStatusCode() const { return _statusCode; }
std::string Response::getStatusText() const { return _statusText; }
std::string Response::getBody() const { return _body; }

std::string Response::getHeader(const std::string& name) const
{
	std::map<std::string, std::string>::const_iterator it = _headers.find(name);
	if (it != _headers.end())
		return it->second;
	return "";
}

std::string Response::toString() const
{
	std::ostringstream oss;
	oss << "HTTP/1.1 " << _statusCode << " " << _statusText << "\r\n";
	for (std::map<std::string, std::string>::const_iterator it = _headers.begin();
		 it != _headers.end(); ++it)
		oss << it->first << ": " << it->second << "\r\n";
	oss << "\r\n" << _body;
	return oss.str();
}

void Response::clear()
{
	_statusCode = 200;
	_statusText = "OK";
	_headers.clear();
	_body.clear();
}

std::string Response::getStatusText(int code)
{
	initStatusTexts();
	std::map<int, std::string>::const_iterator it = _statusTexts.find(code);
	if (it != _statusTexts.end())
		return it->second;
	return "Unknown";
}

std::string Response::getMimeType(const std::string& extension)
{
	if (extension == "html" || extension == "htm")
		return "text/html";
	if (extension == "css")
		return "text/css";
	if (extension == "js")
		return "application/javascript";
	if (extension == "json")
		return "application/json";
	if (extension == "xml")
		return "application/xml";
	if (extension == "txt")
		return "text/plain";
	if (extension == "png")
		return "image/png";
	if (extension == "jpg" || extension == "jpeg")
		return "image/jpeg";
	if (extension == "gif")
		return "image/gif";
	if (extension == "ico")
		return "image/x-icon";
	if (extension == "svg")
		return "image/svg+xml";
	if (extension == "pdf")
		return "application/pdf";
	return "application/octet-stream";
}
