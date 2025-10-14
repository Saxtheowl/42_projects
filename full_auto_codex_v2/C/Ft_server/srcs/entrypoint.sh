#!/bin/bash
set -euo pipefail

log() {
    printf '[entrypoint] %s\n' "$*" >&2
}

ensure_autoindex() {
    local value="${AUTO_INDEX:-off}"
    value=$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')
    if [ "$value" != "on" ]; then
        value="off"
    fi
    export AUTO_INDEX="$value"
    envsubst '${AUTO_INDEX}' < /etc/nginx/templates/default.conf.template > /etc/nginx/sites-available/default
    log "Autoindex set to '$AUTO_INDEX'"
}

start_mysql() {
    if [ ! -d /run/mysqld ]; then
        mkdir -p /run/mysqld
        chown mysql:mysql /run/mysqld
    fi
    service mysql start
}

mysql_with_args() {
    mysql "${MYSQL_CONNECTION_ARGS[@]}" "$@"
}

prepare_mysql_connection() {
    MYSQL_CONNECTION_ARGS=(--protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}")
    if mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
        log "MySQL root password already configured."
        return
    fi
    MYSQL_CONNECTION_ARGS=(--protocol=socket -uroot)
    if mysql "${MYSQL_CONNECTION_ARGS[@]}" -e "SELECT 1" >/dev/null 2>&1; then
        log "Configuring MySQL root password."
        mysql "${MYSQL_CONNECTION_ARGS[@]}" <<-SQL
            ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
            FLUSH PRIVILEGES;
SQL
    fi
    MYSQL_CONNECTION_ARGS=(--protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}")
}

bootstrap_database() {
    log "Ensuring database '${MYSQL_DATABASE}' and user '${MYSQL_USER}'."
    mysql_with_args <<-SQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
        FLUSH PRIVILEGES;
SQL
}

download_and_verify() {
    local url="$1"
    local sha256="$2"
    local destination="$3"

    curl -fsSL "$url" -o "$destination"
    echo "${sha256}  ${destination}" | sha256sum --check --status
}

install_wordpress() {
    local version="$WORDPRESS_VERSION"
    local tarball="/tmp/wordpress-${version}.tar.gz"
    local url="https://wordpress.org/wordpress-${version}.tar.gz"

    if [ ! -f /var/www/html/wp-settings.php ]; then
        log "Installing WordPress ${version}."
        rm -rf /var/www/html/*
        download_and_verify "$url" "$WORDPRESS_SHA256" "$tarball"
        tar -xzf "$tarball" --strip-components=1 -C /var/www/html
        rm -f "$tarball"
        chown -R www-data:www-data /var/www/html
    else
        log "WordPress already present, skipping archive extraction."
    fi
}

generate_salts() {
    local salts
    salts="$(curl -fsSL https://api.wordpress.org/secret-key/1.1/salt/ 2>/dev/null || true)"
    if [ -n "$salts" ]; then
        printf '%s\n' "$salts"
        return
    fi
    local keys=(
        AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY
        AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT
    )
    for key in "${keys[@]}"; do
        local value
        value="$(openssl rand -base64 48 | tr -d '\n')"
        printf "define('%s', '%s');\n" "$key" "$value"
    done
}

configure_wordpress() {
    if [ ! -f /var/www/html/wp-config.php ]; then
        log "Generating wp-config.php."
        cat > /var/www/html/wp-config.php <<-PHP
<?php
define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD', '${MYSQL_PASSWORD}');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

$(generate_salts)

\$table_prefix = 'wp_';
define('WP_DEBUG', false);
define('WP_HOME', '${WORDPRESS_URL}');
define('WP_SITEURL', '${WORDPRESS_URL}');

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
PHP
        chown www-data:www-data /var/www/html/wp-config.php
    fi

    if ! wp core is-installed --allow-root --path=/var/www/html >/dev/null 2>&1; then
        log "Running WordPress core install."
        wp core install \
            --allow-root \
            --path=/var/www/html \
            --url="${WORDPRESS_URL}" \
            --title="${WORDPRESS_TITLE}" \
            --admin_user="${WORDPRESS_ADMIN_USER}" \
            --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
            --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
            --skip-email
    else
        log "WordPress already configured."
    fi
}

install_phpmyadmin() {
    local version="$PHPMYADMIN_VERSION"
    local base="/usr/share/phpmyadmin"
    local tarball="/tmp/phpMyAdmin-${version}.tar.gz"
    local url="https://files.phpmyadmin.net/phpMyAdmin/${version}/phpMyAdmin-${version}-all-languages.tar.gz"

    if [ ! -f "${base}/index.php" ]; then
        log "Installing phpMyAdmin ${version}."
        mkdir -p "$base"
        download_and_verify "$url" "$PHPMYADMIN_SHA256" "$tarball"
        tar -xzf "$tarball" --strip-components=1 -C "$base"
        rm -f "$tarball"
        if [ -f "${base}/config.sample.inc.php" ]; then
            cp "${base}/config.sample.inc.php" "${base}/config.inc.php"
            local secret escaped_secret
            secret="$(openssl rand -base64 32 | tr -d '\n')"
            escaped_secret="$(printf '%s' "$secret" | sed 's/[&]/\\&/g')"
            sed -i "s|\$cfg\['blowfish_secret'\] = ''|\$cfg['blowfish_secret'] = '${escaped_secret}'|g" "${base}/config.inc.php"
        fi
        chown -R www-data:www-data "$base"
    else
        log "phpMyAdmin already present."
    fi
}

main() {
    ensure_autoindex
    start_mysql
    prepare_mysql_connection
    bootstrap_database

    install_wordpress
    configure_wordpress
    install_phpmyadmin

    log "Starting PHP-FPM."
    service php7.3-fpm start

    log "Handing over to process: $*"
    exec "$@"
}

main "$@"
