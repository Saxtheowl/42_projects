/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Request.hpp                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef REQUEST_HPP
# define REQUEST_HPP

# include "webserv.hpp"

class Request
{
public:
	enum State { INCOMPLETE, COMPLETE, ERROR };

private:
	std::string					_method;
	std::string					_uri;
	std::string					_version;
	std::map<std::string, std::string>	_headers;
	std::string					_body;
	std::string					_query;
	State						_state;
	size_t						_contentLength;
	bool						_chunked;
	std::string					_buffer;

	void						parseRequestLine(const std::string& line);
	void						parseHeader(const std::string& line);
	void						parseUri();

public:
	Request();
	Request(const Request& other);
	Request& operator=(const Request& other);
	~Request();

	void						parse(const std::string& data);
	void						clear();

	std::string					getMethod() const;
	std::string					getUri() const;
	std::string					getVersion() const;
	std::string					getHeader(const std::string& name) const;
	std::string					getBody() const;
	std::string					getQuery() const;
	State						getState() const;
	size_t						getContentLength() const;

	bool						isComplete() const;
	bool						hasError() const;
};

#endif
