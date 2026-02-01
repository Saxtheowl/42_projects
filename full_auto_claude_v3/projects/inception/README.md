# Inception - Docker Infrastructure

System administration project using Docker Compose to set up a complete web infrastructure.

## Note

This project requires Docker and Docker Compose to run the actual containers.
Below is the architecture and configuration guide.

## Infrastructure Overview

```
                    ┌─────────────────────────────────────┐
                    │           Host Machine              │
                    │  ┌───────────────────────────────┐  │
                    │  │      Docker Network           │  │
                    │  │                               │  │
    Internet ───────┼──┤►  nginx:443 (TLS)            │  │
                    │  │       │                       │  │
                    │  │       ▼                       │  │
                    │  │   wordpress:9000              │  │
                    │  │       │                       │  │
                    │  │       ▼                       │  │
                    │  │   mariadb:3306               │  │
                    │  │                               │  │
                    │  │   [Volumes]                   │  │
                    │  │   - wordpress_data            │  │
                    │  │   - mariadb_data              │  │
                    │  └───────────────────────────────┘  │
                    └─────────────────────────────────────┘
```

## Services

### 1. NGINX with TLSv1.3
- Reverse proxy
- SSL termination
- Only entry point (port 443)

### 2. WordPress with php-fpm
- PHP-FPM (no nginx)
- WordPress installation
- Connects to MariaDB

### 3. MariaDB
- Database server
- Persistent storage
- Secure initialization

## Directory Structure

```
inception/
├── Makefile
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   └── nginx.conf
│       │   └── tools/
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   └── www.conf
│       │   └── tools/
│       │       └── setup.sh
│       └── mariadb/
│           ├── Dockerfile
│           ├── conf/
│           │   └── 50-server.cnf
│           └── tools/
│               └── init.sh
└── secrets/
```

## Docker Compose Configuration

```yaml
version: '3.8'

services:
  nginx:
    build: ./requirements/nginx
    container_name: nginx
    ports:
      - "443:443"
    volumes:
      - wordpress_data:/var/www/html
    networks:
      - inception
    depends_on:
      - wordpress
    restart: always

  wordpress:
    build: ./requirements/wordpress
    container_name: wordpress
    volumes:
      - wordpress_data:/var/www/html
    networks:
      - inception
    depends_on:
      - mariadb
    environment:
      - WORDPRESS_DB_HOST=mariadb
      - WORDPRESS_DB_USER=${DB_USER}
      - WORDPRESS_DB_PASSWORD=${DB_PASSWORD}
      - WORDPRESS_DB_NAME=${DB_NAME}
    restart: always

  mariadb:
    build: ./requirements/mariadb
    container_name: mariadb
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - inception
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
      - MYSQL_DATABASE=${DB_NAME}
      - MYSQL_USER=${DB_USER}
      - MYSQL_PASSWORD=${DB_PASSWORD}
    restart: always

volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/wordpress

  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/${USER}/data/mariadb

networks:
  inception:
    driver: bridge
```

## Dockerfile Examples

### NGINX Dockerfile
```dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Generate SSL certificate
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=login.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
```

### WordPress Dockerfile
```dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 9000

CMD ["/setup.sh"]
```

### MariaDB Dockerfile
```dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 3306

CMD ["/init.sh"]
```

## Environment Variables (.env)

```bash
# Domain
DOMAIN_NAME=login.42.fr

# Database
DB_NAME=wordpress
DB_USER=wpuser
DB_PASSWORD=secure_password_here
DB_ROOT_PASSWORD=root_password_here

# WordPress
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=admin_password_here
WP_ADMIN_EMAIL=admin@example.com
```

## Makefile

```makefile
NAME = inception

all: build up

build:
	@mkdir -p /home/${USER}/data/wordpress
	@mkdir -p /home/${USER}/data/mariadb
	@docker-compose -f srcs/docker-compose.yml build

up:
	@docker-compose -f srcs/docker-compose.yml up -d

down:
	@docker-compose -f srcs/docker-compose.yml down

clean: down
	@docker system prune -af
	@sudo rm -rf /home/${USER}/data

re: clean all

logs:
	@docker-compose -f srcs/docker-compose.yml logs -f

status:
	@docker-compose -f srcs/docker-compose.yml ps

.PHONY: all build up down clean re logs status
```

## Security Considerations

1. **No passwords in Dockerfiles** - Use environment variables
2. **TLSv1.2 or TLSv1.3 only** - No outdated protocols
3. **No root processes** - Use dedicated users
4. **No :latest tags** - Pin specific versions
5. **No infinite loops** - Use proper entrypoints

## Testing

1. Add to /etc/hosts:
   ```
   127.0.0.1 login.42.fr
   ```

2. Build and run:
   ```bash
   make
   ```

3. Access https://login.42.fr

4. Check services:
   ```bash
   make status
   make logs
   ```

## Bonus Services

- Redis cache for WordPress
- FTP server (vsftpd)
- Adminer (database management)
- Static website
- cAdvisor (monitoring)

## Author

Infrastructure guide for 42 curriculum (system administration track).
