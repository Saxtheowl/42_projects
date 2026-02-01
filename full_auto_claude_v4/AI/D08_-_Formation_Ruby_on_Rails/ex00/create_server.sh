#!/bin/bash
# Ex00: Server provisioning script for Rails development environment
# This script installs RVM, Ruby, Rails, PostgreSQL and creates a sample Rails app

set -e

echo "=== Starting server provisioning ==="

# Update system packages
echo "=== Updating system packages ==="
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
echo "=== Installing required packages ==="
sudo apt-get install -y git curl vim build-essential libssl-dev libreadline-dev zlib1g-dev \
    libpq-dev postgresql postgresql-contrib nodejs

# Configure /etc/hosts - change 127.0.0.1 to 0.0.0.0
echo "=== Configuring /etc/hosts ==="
sudo sed -i 's/127.0.0.1\s*localhost/0.0.0.0 localhost/g' /etc/hosts

# Install RVM (Ruby Version Manager)
echo "=== Installing RVM ==="
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB || true
curl -sSL https://get.rvm.io | bash -s stable

# Load RVM
source ~/.rvm/scripts/rvm

# Install Ruby 2.3.3 (compatible with Rails 4.2.7)
echo "=== Installing Ruby 2.3.3 ==="
rvm install 2.3.3
rvm use 2.3.3 --default

# Install Rails 4.2.7
echo "=== Installing Rails 4.2.7 ==="
gem install rails -v 4.2.7 --no-document
gem install bundler --no-document

# Configure PostgreSQL
echo "=== Configuring PostgreSQL ==="
sudo -u postgres psql -c "CREATE USER vagrant WITH SUPERUSER CREATEDB PASSWORD 'vagrant';" || true
sudo -u postgres psql -c "ALTER USER vagrant WITH SUPERUSER CREATEDB PASSWORD 'vagrant';" || true

# Create site directory and Rails application
echo "=== Creating Rails application 'foubarre' ==="
mkdir -p /home/vagrant/site
cd /home/vagrant/site

# Create new Rails app with PostgreSQL
rails new foubarre -d postgresql
cd foubarre

# Generate scaffold for component
rails g scaffold component great_data

# Add seed data
echo "Component.create(great_data: 'foo_bar_name')" >> db/seeds.rb

# Install gems
bundle install

# Configure database.yml to use vagrant user
sed -i -e "s/username: foubarre/username: vagrant/g" config/database.yml

# Create and setup database in production
echo "=== Setting up production database ==="
RAILS_ENV=production rake db:create
RAILS_ENV=production rake db:migrate
RAILS_ENV=production rake db:seed

# Configure routes - add root route
sed -i "2iroot to: 'components#index'" config/routes.rb

# Update index view to show environment
echo "<h1><%=Rails.env%></h1>" > app/views/components/index.html.erb

# Precompile assets
echo "=== Precompiling assets ==="
RAILS_ENV=production rake assets:precompile

# Generate and set SECRET_KEY_BASE
echo "=== Configuring SECRET_KEY_BASE ==="
SECRET_KEY=$(rake secret)
export SECRET_KEY_BASE=$SECRET_KEY

# Add SECRET_KEY_BASE to bashrc for persistence
echo "export SECRET_KEY_BASE=$SECRET_KEY" >> ~/.bashrc

# Start Puma in production mode
echo "=== Starting Puma server in production mode ==="
cd /home/vagrant/site/foubarre
RAILS_ENV=production SECRET_KEY_BASE=$SECRET_KEY rails server -b 0.0.0.0 -p 3000 -d

echo "=== Server provisioning complete ==="
echo "Rails application 'foubarre' is running at http://localhost:3000"
echo "Environment: production"
