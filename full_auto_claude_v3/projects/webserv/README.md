# Webserv

An HTTP/1.1 server implementation in C++98.

## Description

Webserv is a HTTP server that can serve static files, handle file uploads, and execute CGI scripts. It supports multiple virtual hosts and is configured using a configuration file similar to nginx.

## Features

### HTTP Methods
- **GET**: Retrieve files and directory listings
- **POST**: Upload files and send data to CGI scripts
- **DELETE**: Delete files from the server

### Core Features
- Non-blocking I/O using `select()`
- Multiple simultaneous client connections
- Virtual hosts support
- Custom error pages
- Directory listing (autoindex)
- File uploads
- CGI script execution

### Configuration
- Multiple server blocks
- Location-based routing
- Custom root directories
- Index files
- Client body size limit
- Method restrictions
- URL redirections

## Compilation

```bash
make
```

## Usage

```bash
# With default configuration
./webserv

# With custom configuration file
./webserv config.conf
```

## Configuration File

```nginx
server {
    listen 8080
    server_name localhost

    root ./www
    index index.html

    client_max_body_size 10485760

    error_page 404 ./www/404.html

    location / {
        root ./www
        methods GET POST DELETE
        autoindex on
    }

    location /uploads {
        upload_dir ./www/uploads
        methods GET POST
    }

    location /cgi-bin {
        cgi_extension .py
        cgi_path /usr/bin/python3
        methods GET POST
    }

    location /redirect {
        return https://example.com
    }
}
```

### Configuration Directives

| Directive | Context | Description |
|-----------|---------|-------------|
| `listen` | server | Port number to listen on |
| `server_name` | server | Virtual host name |
| `root` | server, location | Document root directory |
| `index` | server, location | Default index file |
| `client_max_body_size` | server | Maximum request body size |
| `error_page` | server | Custom error page |
| `methods` | location | Allowed HTTP methods |
| `autoindex` | location | Enable directory listing |
| `return` | location | URL redirection |
| `cgi_extension` | location | CGI file extension |
| `cgi_path` | location | CGI interpreter path |
| `upload_dir` | location | Directory for file uploads |

## Examples

### Serving Static Files
```bash
curl http://localhost:8080/
curl http://localhost:8080/style.css
curl http://localhost:8080/images/logo.png
```

### File Upload
```bash
curl -X POST -d "content here" http://localhost:8080/uploads
curl -X POST -F "file=@myfile.txt" http://localhost:8080/uploads
```

### File Deletion
```bash
curl -X DELETE http://localhost:8080/uploads/myfile.txt
```

### CGI Script
```bash
curl http://localhost:8080/cgi-bin/script.py
curl -X POST -d "name=test" http://localhost:8080/cgi-bin/form.py
```

## Directory Structure

```
webserv/
├── src/
│   ├── webserv.hpp       # Common includes
│   ├── Location.hpp/cpp  # Location configuration
│   ├── ServerConfig.hpp/cpp # Server configuration
│   ├── Request.hpp/cpp   # HTTP request parsing
│   ├── Response.hpp/cpp  # HTTP response generation
│   ├── Server.hpp/cpp    # Main server logic
│   ├── Handler.cpp       # Request handlers
│   └── main.cpp          # Entry point
├── www/                  # Default document root
│   └── index.html
├── webserv.conf          # Default configuration
├── Makefile
└── README.md
```

## HTTP Response Codes

| Code | Description |
|------|-------------|
| 200 | OK |
| 201 | Created |
| 301 | Moved Permanently |
| 400 | Bad Request |
| 403 | Forbidden |
| 404 | Not Found |
| 405 | Method Not Allowed |
| 413 | Payload Too Large |
| 500 | Internal Server Error |
| 501 | Not Implemented |

## Allowed Functions

- `socket`, `setsockopt`, `getsockname`, `bind`, `listen`, `accept`
- `send`, `recv`, `close`
- `select` (or `poll`, `epoll`, `kqueue`)
- `fcntl`, `read`, `write`
- `open`, `close`, `stat`, `opendir`, `readdir`, `closedir`
- `fork`, `execve`, `waitpid`, `kill`
- `signal`, `sigaction`

## Testing

```bash
# Start server
./webserv

# Test with curl
curl -v http://localhost:8080/

# Test with siege
siege -c 50 -t 30s http://localhost:8080/
```

## Author

Implementation for 42 curriculum.
