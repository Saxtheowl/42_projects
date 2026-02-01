/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Handler.cpp                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Server.hpp"

std::string Server::getFilePath(const Request& req, const ServerConfig& conf,
								const Location* loc)
{
	std::string uri = req.getUri();
	std::string root = loc ? loc->getRoot() : conf.getRoot();
	if (root.empty())
		root = conf.getRoot();

	std::string locPath = loc ? loc->getPath() : "";
	std::string relPath = uri.substr(locPath.length());

	if (!root.empty() && root[root.length()-1] != '/')
		root += "/";
	while (!relPath.empty() && relPath[0] == '/')
		relPath.erase(0, 1);

	return root + relPath;
}

void Server::processRequest(ClientInfo& client)
{
	const Request& req = client.request;
	ServerConfig& conf = *client.config;

	std::cout << req.getMethod() << " " << req.getUri() << std::endl;

	if (req.getBody().length() > conf.getMaxBodySize())
	{
		sendError(client, 413);
		return;
	}

	const Location* loc = conf.findLocation(req.getUri());

	if (loc && !loc->getRedirect().empty())
	{
		sendRedirect(client, loc->getRedirect());
		return;
	}

	if (loc && !loc->isMethodAllowed(req.getMethod()))
	{
		sendError(client, 405);
		return;
	}

	if (loc && !loc->getCgiExtension().empty())
	{
		std::string uri = req.getUri();
		if (uri.find(loc->getCgiExtension()) != std::string::npos)
		{
			handleCgi(client, loc);
			return;
		}
	}

	if (req.getMethod() == "GET")
		handleGet(client, loc);
	else if (req.getMethod() == "POST")
		handlePost(client, loc);
	else if (req.getMethod() == "DELETE")
		handleDelete(client, loc);
	else
		sendError(client, 501);
}

void Server::handleGet(ClientInfo& client, const Location* loc)
{
	std::string path = getFilePath(client.request, *client.config, loc);

	if (isDirectory(path))
	{
		std::string index = loc ? loc->getIndex() : client.config->getIndex();
		if (index.empty())
			index = client.config->getIndex();
		std::string indexPath = path;
		if (indexPath[indexPath.length()-1] != '/')
			indexPath += "/";
		indexPath += index;

		if (fileExists(indexPath))
		{
			serveFile(client, indexPath);
		}
		else if (loc && loc->isAutoindex())
		{
			serveDirectory(client, path);
		}
		else
		{
			sendError(client, 403);
		}
	}
	else if (fileExists(path))
	{
		serveFile(client, path);
	}
	else
	{
		sendError(client, 404);
	}
}

void Server::handlePost(ClientInfo& client, const Location* loc)
{
	if (!loc || loc->getUploadDir().empty())
	{
		sendError(client, 403);
		return;
	}

	std::string uploadDir = loc->getUploadDir();
	if (uploadDir[uploadDir.length()-1] != '/')
		uploadDir += "/";

	std::string filename = "upload_" +
		static_cast<std::ostringstream&>(std::ostringstream() << std::time(NULL)).str();

	std::string contentType = client.request.getHeader("Content-Type");
	if (contentType.find("multipart/form-data") != std::string::npos)
		filename += ".bin";
	else
		filename += ".txt";

	std::string path = uploadDir + filename;
	std::ofstream file(path.c_str(), std::ios::binary);
	if (!file.is_open())
	{
		sendError(client, 500);
		return;
	}
	file << client.request.getBody();
	file.close();

	client.response.setStatus(201);
	client.response.setContentType("text/html");
	client.response.setBody("<html><body><h1>File uploaded successfully</h1></body></html>");
}

void Server::handleDelete(ClientInfo& client, const Location* loc)
{
	std::string path = getFilePath(client.request, *client.config, loc);

	if (!fileExists(path))
	{
		sendError(client, 404);
		return;
	}

	if (isDirectory(path))
	{
		sendError(client, 403);
		return;
	}

	if (unlink(path.c_str()) != 0)
	{
		sendError(client, 500);
		return;
	}

	client.response.setStatus(200);
	client.response.setContentType("text/html");
	client.response.setBody("<html><body><h1>File deleted successfully</h1></body></html>");
}

void Server::handleCgi(ClientInfo& client, const Location* loc)
{
	std::string path = getFilePath(client.request, *client.config, loc);
	std::string cgiPath = loc->getCgiPath();

	if (!fileExists(path))
	{
		sendError(client, 404);
		return;
	}

	int pipefd[2];
	if (pipe(pipefd) < 0)
	{
		sendError(client, 500);
		return;
	}

	pid_t pid = fork();
	if (pid < 0)
	{
		close(pipefd[0]);
		close(pipefd[1]);
		sendError(client, 500);
		return;
	}

	if (pid == 0)
	{
		close(pipefd[0]);
		dup2(pipefd[1], STDOUT_FILENO);
		close(pipefd[1]);

		std::vector<std::string> envVars;
		envVars.push_back("REQUEST_METHOD=" + client.request.getMethod());
		envVars.push_back("QUERY_STRING=" + client.request.getQuery());
		envVars.push_back("CONTENT_LENGTH=" +
			static_cast<std::ostringstream&>(std::ostringstream() <<
			client.request.getBody().length()).str());
		envVars.push_back("CONTENT_TYPE=" + client.request.getHeader("Content-Type"));
		envVars.push_back("SCRIPT_FILENAME=" + path);
		envVars.push_back("PATH_INFO=" + client.request.getUri());

		char** envp = new char*[envVars.size() + 1];
		for (size_t i = 0; i < envVars.size(); i++)
			envp[i] = strdup(envVars[i].c_str());
		envp[envVars.size()] = NULL;

		char* argv[3];
		argv[0] = strdup(cgiPath.c_str());
		argv[1] = strdup(path.c_str());
		argv[2] = NULL;

		execve(cgiPath.c_str(), argv, envp);
		std::exit(1);
	}

	close(pipefd[1]);

	std::string output;
	char buffer[4096];
	int bytesRead;
	while ((bytesRead = read(pipefd[0], buffer, sizeof(buffer))) > 0)
		output.append(buffer, bytesRead);
	close(pipefd[0]);

	int status;
	waitpid(pid, &status, 0);

	size_t headerEnd = output.find("\r\n\r\n");
	if (headerEnd == std::string::npos)
		headerEnd = output.find("\n\n");

	if (headerEnd != std::string::npos)
	{
		std::string headers = output.substr(0, headerEnd);
		std::string body = output.substr(headerEnd + (output[headerEnd+1] == '\n' ? 2 : 4));

		client.response.setStatus(200);
		std::istringstream iss(headers);
		std::string line;
		while (std::getline(iss, line))
		{
			if (!line.empty() && line[line.size()-1] == '\r')
				line.erase(line.size()-1);
			size_t pos = line.find(':');
			if (pos != std::string::npos)
			{
				std::string name = line.substr(0, pos);
				std::string value = line.substr(pos + 2);
				client.response.setHeader(name, value);
			}
		}
		client.response.setBody(body);
	}
	else
	{
		client.response.setStatus(200);
		client.response.setContentType("text/html");
		client.response.setBody(output);
	}
}

void Server::sendError(ClientInfo& client, int code)
{
	std::string errorPage = client.config->getErrorPage(code);
	if (!errorPage.empty() && fileExists(errorPage))
	{
		serveFile(client, errorPage);
		client.response.setStatus(code);
		return;
	}

	client.response.setStatus(code);
	client.response.setContentType("text/html");
	std::ostringstream oss;
	oss << "<html><head><title>" << code << " " << Response::getStatusText(code)
		<< "</title></head><body><h1>" << code << " " << Response::getStatusText(code)
		<< "</h1></body></html>";
	client.response.setBody(oss.str());
}

void Server::sendRedirect(ClientInfo& client, const std::string& url)
{
	client.response.setStatus(301);
	client.response.setHeader("Location", url);
	client.response.setContentType("text/html");
	client.response.setBody("<html><body><h1>Moved Permanently</h1></body></html>");
}

void Server::serveFile(ClientInfo& client, const std::string& path)
{
	std::string content = readFile(path);
	if (content.empty() && !fileExists(path))
	{
		sendError(client, 404);
		return;
	}

	size_t dotPos = path.rfind('.');
	std::string ext = dotPos != std::string::npos ? path.substr(dotPos + 1) : "";

	client.response.setStatus(200);
	client.response.setContentType(Response::getMimeType(ext));
	client.response.setBody(content);
}

void Server::serveDirectory(ClientInfo& client, const std::string& path)
{
	DIR* dir = opendir(path.c_str());
	if (!dir)
	{
		sendError(client, 500);
		return;
	}

	std::ostringstream oss;
	oss << "<html><head><title>Index of " << client.request.getUri()
		<< "</title></head><body><h1>Index of " << client.request.getUri()
		<< "</h1><ul>";

	struct dirent* entry;
	while ((entry = readdir(dir)) != NULL)
	{
		std::string name = entry->d_name;
		if (name == ".")
			continue;
		std::string uri = client.request.getUri();
		if (uri[uri.length()-1] != '/')
			uri += "/";
		oss << "<li><a href=\"" << uri << name << "\">" << name << "</a></li>";
	}
	closedir(dir);

	oss << "</ul></body></html>";

	client.response.setStatus(200);
	client.response.setContentType("text/html");
	client.response.setBody(oss.str());
}
