/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Server.cpp                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Server.hpp"

bool g_running = true;

Server::Server() : _running(true) {}

Server::~Server()
{
	for (std::map<int, int>::iterator it = _listenFds.begin();
		 it != _listenFds.end(); ++it)
		close(it->first);
	for (std::map<int, ClientInfo>::iterator it = _clients.begin();
		 it != _clients.end(); ++it)
		close(it->first);
}

void Server::addConfig(const ServerConfig& config)
{
	_configs.push_back(config);
}

void Server::loadConfig(const std::string& filename)
{
	std::ifstream file(filename.c_str());
	if (!file.is_open())
		throw std::runtime_error("Cannot open config file: " + filename);

	ServerConfig config;
	Location currentLoc;
	bool inLocation = false;
	std::string line;

	while (std::getline(file, line))
	{
		while (!line.empty() && (line[0] == ' ' || line[0] == '\t'))
			line.erase(0, 1);
		if (line.empty() || line[0] == '#')
			continue;

		std::istringstream iss(line);
		std::string directive;
		iss >> directive;

		if (directive == "server")
		{
			if (!_configs.empty() || config.getPort() != DEFAULT_PORT)
			{
				_configs.push_back(config);
				config = ServerConfig();
			}
		}
		else if (directive == "listen")
		{
			int port;
			iss >> port;
			config.setPort(port);
		}
		else if (directive == "server_name")
		{
			std::string name;
			iss >> name;
			config.setServerName(name);
		}
		else if (directive == "root")
		{
			std::string root;
			iss >> root;
			if (inLocation)
				currentLoc.setRoot(root);
			else
				config.setRoot(root);
		}
		else if (directive == "index")
		{
			std::string index;
			iss >> index;
			if (inLocation)
				currentLoc.setIndex(index);
			else
				config.setIndex(index);
		}
		else if (directive == "client_max_body_size")
		{
			size_t size;
			iss >> size;
			config.setMaxBodySize(size);
		}
		else if (directive == "error_page")
		{
			int code;
			std::string path;
			iss >> code >> path;
			config.setErrorPage(code, path);
		}
		else if (directive == "location")
		{
			if (inLocation)
				config.addLocation(currentLoc);
			std::string path;
			iss >> path;
			currentLoc = Location(path);
			inLocation = true;
		}
		else if (directive == "allow_methods" || directive == "methods")
		{
			std::string method;
			while (iss >> method)
				currentLoc.addMethod(method);
		}
		else if (directive == "autoindex")
		{
			std::string value;
			iss >> value;
			currentLoc.setAutoindex(value == "on");
		}
		else if (directive == "return" || directive == "redirect")
		{
			std::string url;
			iss >> url;
			currentLoc.setRedirect(url);
		}
		else if (directive == "cgi_extension")
		{
			std::string ext;
			iss >> ext;
			currentLoc.setCgiExtension(ext);
		}
		else if (directive == "cgi_path")
		{
			std::string path;
			iss >> path;
			currentLoc.setCgiPath(path);
		}
		else if (directive == "upload_dir")
		{
			std::string dir;
			iss >> dir;
			currentLoc.setUploadDir(dir);
		}
		else if (directive == "}")
		{
			if (inLocation)
			{
				config.addLocation(currentLoc);
				inLocation = false;
			}
		}
	}

	if (inLocation)
		config.addLocation(currentLoc);
	_configs.push_back(config);
}

void Server::initSockets()
{
	std::set<int> ports;
	for (size_t i = 0; i < _configs.size(); i++)
		ports.insert(_configs[i].getPort());

	for (std::set<int>::iterator it = ports.begin(); it != ports.end(); ++it)
	{
		int port = *it;
		int fd = socket(AF_INET, SOCK_STREAM, 0);
		if (fd < 0)
			throw std::runtime_error("Failed to create socket");

		int opt = 1;
		setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
		fcntl(fd, F_SETFL, O_NONBLOCK);

		struct sockaddr_in addr;
		std::memset(&addr, 0, sizeof(addr));
		addr.sin_family = AF_INET;
		addr.sin_addr.s_addr = INADDR_ANY;
		addr.sin_port = htons(port);

		if (bind(fd, (struct sockaddr*)&addr, sizeof(addr)) < 0)
			throw std::runtime_error("Failed to bind socket on port " +
				static_cast<std::ostringstream&>(std::ostringstream() << port).str());

		if (listen(fd, MAX_CLIENTS) < 0)
			throw std::runtime_error("Failed to listen on socket");

		_listenFds[fd] = port;
		std::cout << "Listening on port " << port << std::endl;
	}
}

void Server::run()
{
	initSockets();
	fd_set readFds, writeFds;
	int maxFd;

	while (_running && g_running)
	{
		FD_ZERO(&readFds);
		FD_ZERO(&writeFds);
		maxFd = 0;

		for (std::map<int, int>::iterator it = _listenFds.begin();
			 it != _listenFds.end(); ++it)
		{
			FD_SET(it->first, &readFds);
			if (it->first > maxFd)
				maxFd = it->first;
		}

		for (std::map<int, ClientInfo>::iterator it = _clients.begin();
			 it != _clients.end(); ++it)
		{
			if (it->second.responseBuffer.empty())
				FD_SET(it->first, &readFds);
			else
				FD_SET(it->first, &writeFds);
			if (it->first > maxFd)
				maxFd = it->first;
		}

		struct timeval tv;
		tv.tv_sec = 1;
		tv.tv_usec = 0;

		int activity = select(maxFd + 1, &readFds, &writeFds, NULL, &tv);
		if (activity < 0)
		{
			if (errno == EINTR)
				continue;
			break;
		}

		for (std::map<int, int>::iterator it = _listenFds.begin();
			 it != _listenFds.end(); ++it)
		{
			if (FD_ISSET(it->first, &readFds))
				handleNewConnection(it->first);
		}

		std::vector<int> toRemove;
		for (std::map<int, ClientInfo>::iterator it = _clients.begin();
			 it != _clients.end(); ++it)
		{
			if (FD_ISSET(it->first, &readFds))
				handleClientRead(it->first);
			else if (FD_ISSET(it->first, &writeFds))
				handleClientWrite(it->first);
		}
	}
}

void Server::stop()
{
	_running = false;
}

void Server::handleNewConnection(int listenFd)
{
	struct sockaddr_in addr;
	socklen_t addrLen = sizeof(addr);
	int clientFd = accept(listenFd, (struct sockaddr*)&addr, &addrLen);
	if (clientFd < 0)
		return;

	fcntl(clientFd, F_SETFL, O_NONBLOCK);

	ClientInfo info;
	info.fd = clientFd;
	info.bytesSent = 0;
	info.config = findConfig(_listenFds[listenFd], "");
	_clients[clientFd] = info;

	std::cout << "New connection on fd " << clientFd << std::endl;
}

void Server::handleClientRead(int clientFd)
{
	char buffer[BUFFER_SIZE];
	int bytesRead = recv(clientFd, buffer, sizeof(buffer), 0);

	if (bytesRead <= 0)
	{
		removeClient(clientFd);
		return;
	}

	ClientInfo& client = _clients[clientFd];
	client.request.parse(std::string(buffer, bytesRead));

	if (client.request.isComplete())
	{
		std::string host = client.request.getHeader("Host");
		client.config = findConfig(_listenFds.begin()->second, host);
		processRequest(client);
		client.responseBuffer = client.response.toString();
		client.bytesSent = 0;
	}
	else if (client.request.hasError())
	{
		sendError(client, 400);
		client.responseBuffer = client.response.toString();
		client.bytesSent = 0;
	}
}

void Server::handleClientWrite(int clientFd)
{
	ClientInfo& client = _clients[clientFd];
	size_t remaining = client.responseBuffer.length() - client.bytesSent;
	int sent = send(clientFd, client.responseBuffer.c_str() + client.bytesSent,
					remaining, 0);

	if (sent <= 0)
	{
		removeClient(clientFd);
		return;
	}

	client.bytesSent += sent;
	if (client.bytesSent >= client.responseBuffer.length())
	{
		std::string connection = client.request.getHeader("Connection");
		if (connection == "close")
			removeClient(clientFd);
		else
		{
			client.request.clear();
			client.response.clear();
			client.responseBuffer.clear();
			client.bytesSent = 0;
		}
	}
}

void Server::removeClient(int clientFd)
{
	close(clientFd);
	_clients.erase(clientFd);
}

ServerConfig* Server::findConfig(int port, const std::string& host)
{
	for (size_t i = 0; i < _configs.size(); i++)
	{
		if (_configs[i].getPort() == port &&
			(host.empty() || _configs[i].getServerName() == host ||
			 host.find(_configs[i].getServerName()) != std::string::npos))
			return &_configs[i];
	}
	for (size_t i = 0; i < _configs.size(); i++)
	{
		if (_configs[i].getPort() == port)
			return &_configs[i];
	}
	if (!_configs.empty())
		return &_configs[0];
	return NULL;
}

std::string Server::readFile(const std::string& path)
{
	std::ifstream file(path.c_str(), std::ios::binary);
	if (!file.is_open())
		return "";
	std::ostringstream oss;
	oss << file.rdbuf();
	return oss.str();
}

bool Server::fileExists(const std::string& path)
{
	struct stat st;
	return stat(path.c_str(), &st) == 0;
}

bool Server::isDirectory(const std::string& path)
{
	struct stat st;
	if (stat(path.c_str(), &st) != 0)
		return false;
	return S_ISDIR(st.st_mode);
}
