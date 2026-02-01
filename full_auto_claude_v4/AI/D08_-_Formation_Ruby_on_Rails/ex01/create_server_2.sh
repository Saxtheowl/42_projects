#!/bin/bash
# Ex01: Production server provisioning script
# Creates deploy user, installs nginx, RVM, Ruby, PostgreSQL for Capistrano deployment

set -e

echo "=== Starting production server provisioning ==="

# Update system packages
echo "=== Updating system packages ==="
apt-get update -y
apt-get upgrade -y

# Install required packages
echo "=== Installing required packages ==="
apt-get install -y git curl vim build-essential libssl-dev libreadline-dev zlib1g-dev \
    libpq-dev postgresql postgresql-contrib nodejs nginx

# Create deploy user
echo "=== Creating deploy user ==="
if ! id -u deploy > /dev/null 2>&1; then
    useradd -m -s /bin/bash deploy
    echo "deploy:deploy" | chpasswd
    usermod -aG sudo deploy
fi

# Configure sudo for deploy user (no password required)
echo "deploy ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/deploy
chmod 0440 /etc/sudoers.d/deploy

# Setup SSH for deploy user
echo "=== Setting up SSH for deploy user ==="
mkdir -p /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
touch /home/deploy/.ssh/authorized_keys
chmod 600 /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh

# Configure /etc/hosts
echo "=== Configuring /etc/hosts ==="
sed -i 's/127.0.0.1\s*localhost/0.0.0.0 localhost/g' /etc/hosts

# Configure PostgreSQL
echo "=== Configuring PostgreSQL ==="
sudo -u postgres psql -c "CREATE USER deploy WITH SUPERUSER CREATEDB PASSWORD 'deploy';" || true
sudo -u postgres psql -c "ALTER USER deploy WITH SUPERUSER CREATEDB PASSWORD 'deploy';" || true

# Install RVM for deploy user
echo "=== Installing RVM for deploy user ==="
su - deploy -c 'gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB || true'
su - deploy -c 'curl -sSL https://get.rvm.io | bash -s stable'

# Install Ruby for deploy user
echo "=== Installing Ruby 2.3.3 for deploy user ==="
su - deploy -c 'source ~/.rvm/scripts/rvm && rvm install 2.3.3 && rvm use 2.3.3 --default'
su - deploy -c 'source ~/.rvm/scripts/rvm && gem install bundler --no-document'

# Create application directory structure for Capistrano
echo "=== Creating application directory structure ==="
mkdir -p /var/www/foubarre
mkdir -p /var/www/foubarre/shared/config
mkdir -p /var/www/foubarre/shared/log
mkdir -p /var/www/foubarre/shared/tmp/pids
mkdir -p /var/www/foubarre/shared/tmp/sockets
chown -R deploy:deploy /var/www/foubarre

# Create shared database.yml
cat > /var/www/foubarre/shared/config/database.yml << 'EOF'
production:
  adapter: postgresql
  encoding: unicode
  database: foubarre_production
  pool: 5
  username: deploy
  password: deploy
  host: localhost
EOF
chown deploy:deploy /var/www/foubarre/shared/config/database.yml

# Create shared secrets.yml with SECRET_KEY_BASE
SECRET_KEY=$(openssl rand -hex 64)
cat > /var/www/foubarre/shared/config/secrets.yml << EOF
production:
  secret_key_base: $SECRET_KEY
EOF
chown deploy:deploy /var/www/foubarre/shared/config/secrets.yml

# Configure Nginx
echo "=== Configuring Nginx ==="
cat > /etc/nginx/sites-available/foubarre << 'EOF'
upstream puma {
    server unix:///var/www/foubarre/shared/tmp/sockets/puma.sock fail_timeout=0;
}

server {
    listen 80;
    server_name localhost;

    root /var/www/foubarre/current/public;

    try_files $uri/index.html $uri @puma;

    location @puma {
        proxy_pass http://puma;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }

    location ~ ^/(assets|packs)/ {
        gzip_static on;
        expires max;
        add_header Cache-Control public;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 10M;
    keepalive_timeout 10;
}
EOF

# Enable the site
ln -sf /etc/nginx/sites-available/foubarre /etc/nginx/sites-enabled/foubarre
rm -f /etc/nginx/sites-enabled/default

# Test and restart nginx
nginx -t
systemctl restart nginx
systemctl enable nginx

# Create production database
echo "=== Creating production database ==="
sudo -u postgres createdb foubarre_production -O deploy || true

echo "=== Production server provisioning complete ==="
echo "Server is ready for Capistrano deployment"
echo "Deploy user: deploy"
echo "Application path: /var/www/foubarre"
echo "Nginx configured to proxy to Puma"
