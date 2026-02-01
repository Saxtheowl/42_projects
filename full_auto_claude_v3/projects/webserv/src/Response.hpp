/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Response.hpp                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef RESPONSE_HPP
# define RESPONSE_HPP

# include "webserv.hpp"

class Response
{
private:
	int							_statusCode;
	std::string					_statusText;
	std::map<std::string, std::string>	_headers;
	std::string					_body;

	static std::map<int, std::string>	_statusTexts;
	static void						initStatusTexts();

public:
	Response();
	Response(const Response& other);
	Response& operator=(const Response& other);
	~Response();

	void						setStatus(int code);
	void						setStatus(int code, const std::string& text);
	void						setHeader(const std::string& name, const std::string& value);
	void						setBody(const std::string& body);
	void						setContentType(const std::string& type);

	int							getStatusCode() const;
	std::string					getStatusText() const;
	std::string					getHeader(const std::string& name) const;
	std::string					getBody() const;

	std::string					toString() const;
	void						clear();

	static std::string			getStatusText(int code);
	static std::string			getMimeType(const std::string& extension);
};

#endif
