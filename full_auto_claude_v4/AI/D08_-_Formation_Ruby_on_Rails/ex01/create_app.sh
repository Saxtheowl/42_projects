#!/bin/bash
# Ex01: Creates a Rails application configured for Capistrano deployment
# Run this script on your local development machine

set -e

APP_NAME="foubarre"
BITBUCKET_USER="${BITBUCKET_USER:-your_username}"
SERVER_IP="${SERVER_IP:-192.168.33.20}"

echo "=== Creating Rails application for Capistrano deployment ==="

# Create Rails application
echo "=== Creating new Rails app: $APP_NAME ==="
rails new $APP_NAME -d postgresql
cd $APP_NAME

# Generate scaffold
rails g scaffold component great_data

# Add seed data
echo "Component.create(great_data: 'foo_bar_name')" >> db/seeds.rb

# Configure routes
sed -i "2iroot to: 'components#index'" config/routes.rb

# Update index view
echo "<h1><%=Rails.env%></h1>" > app/views/components/index.html.erb

# Add Capistrano and deployment gems to Gemfile
cat >> Gemfile << 'EOF'

# Deployment gems
group :development do
  gem 'capistrano', '~> 3.11'
  gem 'capistrano-rails', '~> 1.4'
  gem 'capistrano-bundler', '~> 1.6'
  gem 'capistrano-rvm'
  gem 'capistrano3-puma', '~> 4.0'
end

# Production server
gem 'puma', '~> 3.12'
EOF

# Install gems
bundle install

# Initialize Capistrano
bundle exec cap install

# Configure Capfile
cat > Capfile << 'EOF'
# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include RVM support
require 'capistrano/rvm'

# Include bundler support
require 'capistrano/bundler'

# Include Rails support
require 'capistrano/rails'

# Include Puma support
require 'capistrano3/puma'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

# Load custom tasks from lib/capistrano/tasks
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
EOF

# Configure deploy.rb
cat > config/deploy.rb << EOF
# config valid for current version and target modules of Capistrano
lock '~> 3.11'

set :application, '$APP_NAME'
set :repo_url, 'git@bitbucket.org:$BITBUCKET_USER/$APP_NAME.git'

# Default deploy_to directory
set :deploy_to, '/var/www/$APP_NAME'

# Default value for :linked_files
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

# RVM configuration
set :rvm_type, :user
set :rvm_ruby_version, '2.3.3'

# Puma configuration
set :puma_threads, [4, 16]
set :puma_workers, 0
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log, "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil

# Keep only the last 5 releases
set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after :publishing, :restart
end
EOF

# Configure production stage
cat > config/deploy/production.rb << EOF
server '$SERVER_IP', user: 'deploy', roles: %w{app db web}

set :ssh_options, {
  forward_agent: true,
  auth_methods: %w[publickey]
}
EOF

# Create nginx.conf for reference
mkdir -p config/nginx
cat > config/nginx/foubarre.conf << 'EOF'
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

# Create post_deploy_symlink.sh script
cat > post_deploy_symlink.sh << 'EOF'
#!/bin/bash
# Post-deployment symlink script
# Creates necessary symlinks after Capistrano deployment

DEPLOY_PATH="/var/www/foubarre"

# Ensure shared directories exist
mkdir -p $DEPLOY_PATH/shared/config
mkdir -p $DEPLOY_PATH/shared/log
mkdir -p $DEPLOY_PATH/shared/tmp/pids
mkdir -p $DEPLOY_PATH/shared/tmp/sockets
mkdir -p $DEPLOY_PATH/shared/public/system

# Link shared files to current release
ln -sfn $DEPLOY_PATH/shared/config/database.yml $DEPLOY_PATH/current/config/database.yml
ln -sfn $DEPLOY_PATH/shared/config/secrets.yml $DEPLOY_PATH/current/config/secrets.yml

echo "Symlinks created successfully"
EOF
chmod +x post_deploy_symlink.sh

# Configure Puma for production
cat > config/puma.rb << 'EOF'
# Puma configuration file

# Threads per worker
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Specifies the `environment` that Puma will run in
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `port` that Puma will listen on to receive requests
# port ENV.fetch("PORT") { 3000 }

# Production settings
if ENV.fetch("RAILS_ENV") { "development" } == "production"
  # Bind to socket
  app_dir = File.expand_path("../..", __FILE__)
  shared_dir = "#{app_dir}/../../shared"

  bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

  # Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

  # PID and state files
  pidfile "#{shared_dir}/tmp/pids/puma.pid"
  state_path "#{shared_dir}/tmp/pids/puma.state"

  # Daemonize
  daemonize true

  # Workers (0 for single mode)
  workers 0

  # Preload app for better memory usage
  preload_app!

  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end
EOF

echo "=== Rails application created and configured ==="
echo ""
echo "Next steps:"
echo "1. Initialize git repository:"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial commit'"
echo ""
echo "2. Create Bitbucket repository and push:"
echo "   git remote add origin git@bitbucket.org:$BITBUCKET_USER/$APP_NAME.git"
echo "   git push -u origin master"
echo ""
echo "3. Copy your SSH public key to the server:"
echo "   ssh-copy-id deploy@$SERVER_IP"
echo ""
echo "4. Deploy with Capistrano:"
echo "   cap production deploy"
