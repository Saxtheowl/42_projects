FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gettext-base \
    mariadb-server \
    nginx \
    openssl \
    php-cli \
    php-curl \
    php-fpm \
    php-gd \
    php-mbstring \
    php-mysql \
    php-xml \
    php-zip \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Student/CN=ft_server" \
        -keyout /etc/nginx/ssl/ft_server.key \
        -out /etc/nginx/ssl/ft_server.crt

COPY srcs/nginx.conf.template /etc/nginx/templates/default.conf.template
COPY srcs/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -o /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

EXPOSE 80 443
WORKDIR /var/www/html

ENV AUTO_INDEX=off \
    MYSQL_ROOT_PASSWORD=changeme \
    MYSQL_DATABASE=wordpress \
    MYSQL_USER=wp_user \
    MYSQL_PASSWORD=wp_password \
    WORDPRESS_VERSION=6.5.3 \
    WORDPRESS_SHA256=526c0ff9def5311d189de56360770e3429805036d0754a5bd11bd4decca0ca6c \
    PHPMYADMIN_VERSION=5.2.1 \
    PHPMYADMIN_SHA256=61c763f209817d1b5d96a4c0eab65b4e36bce744f78e73bef3bebd1c07481c46 \
    WORDPRESS_URL=https://localhost \
    WORDPRESS_TITLE="ft_server" \
    WORDPRESS_ADMIN_USER=admin \
    WORDPRESS_ADMIN_PASSWORD=adminpass \
    WORDPRESS_ADMIN_EMAIL=admin@example.com

ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
