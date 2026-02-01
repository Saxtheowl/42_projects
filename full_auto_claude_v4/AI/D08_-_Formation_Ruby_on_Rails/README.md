# D08 - Formation Ruby on Rails: DevOps & Deployment

This project covers the deployment of Ruby on Rails applications using Vagrant, nginx, Puma, and Capistrano.

## Project Structure

```
D08_-_Formation_Ruby_on_Rails/
├── ex00/
│   ├── create_server.sh    # VM provisioning script
│   └── Vagrantfile         # Vagrant configuration
├── ex01/
│   ├── create_app.sh       # Rails app with Capistrano setup
│   ├── create_server_2.sh  # Production server provisioning
│   └── Vagrantfile         # Vagrant configuration
├── test_scripts.sh         # Validation tests
└── README.md
```

## Exercise 00: Basic Rails Server

Provisions a Vagrant VM with:
- RVM (Ruby Version Manager)
- Ruby 2.3.3
- Rails 4.2.7
- PostgreSQL
- A sample "foubarre" Rails application running on Puma

### Usage

```bash
cd ex00
vagrant up
```

The application will be accessible at `http://localhost:3000`

### What the Script Does

1. Updates system packages
2. Installs git, curl, vim, and build tools
3. Configures `/etc/hosts` (changes 127.0.0.1 to 0.0.0.0)
4. Installs RVM and Ruby 2.3.3
5. Installs Rails 4.2.7
6. Creates PostgreSQL user
7. Creates "foubarre" Rails app with scaffold
8. Sets up production database (create, migrate, seed)
9. Precompiles assets
10. Configures SECRET_KEY_BASE
11. Starts Puma server in production mode

## Exercise 01: Production Deployment with Capistrano

Sets up a production-ready Rails deployment:
- nginx as reverse proxy
- Puma as application server
- Capistrano for automated deployment
- Deploy user with SSH key authentication

### Server Setup

```bash
cd ex01
vagrant up
```

### Application Setup (Local)

```bash
# On your development machine
./create_app.sh

# Follow the instructions to:
# 1. Initialize git repository
# 2. Push to Bitbucket
# 3. Copy SSH keys
# 4. Deploy with Capistrano
```

### Capistrano Deployment

```bash
cd foubarre
cap production deploy
```

### Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│    Nginx    │────▶│    Puma     │
│  (Browser)  │     │  (Port 80)  │     │  (Socket)   │
└─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   Rails     │
                    │   App       │
                    └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ PostgreSQL  │
                    └─────────────┘
```

### Directory Structure on Server

```
/var/www/foubarre/
├── current -> releases/YYYYMMDDHHMMSS
├── releases/
│   └── YYYYMMDDHHMMSS/
├── shared/
│   ├── config/
│   │   ├── database.yml
│   │   └── secrets.yml
│   ├── log/
│   └── tmp/
│       ├── pids/
│       └── sockets/
└── repo/
```

## Test Credentials

| Component | User | Password |
|-----------|------|----------|
| PostgreSQL (ex00) | vagrant | vagrant |
| PostgreSQL (ex01) | deploy | deploy |
| Deploy user | deploy | deploy |

## Requirements

- VirtualBox
- Vagrant
- (For ex01) SSH key pair
- (For ex01) Bitbucket account

## Running Tests

```bash
./test_scripts.sh
```

## Technology Stack

- **VM**: Vagrant + VirtualBox
- **OS**: Ubuntu 14.04 (Trusty)
- **Ruby**: 2.3.3 (via RVM)
- **Rails**: 4.2.7
- **Database**: PostgreSQL
- **Web Server**: nginx
- **App Server**: Puma
- **Deployment**: Capistrano 3.x

## Notes

- The `/etc/hosts` modification (0.0.0.0 instead of 127.0.0.1) allows the Rails server to accept connections from all interfaces
- SECRET_KEY_BASE must be set for production mode
- Asset precompilation is required for production
- Capistrano handles zero-downtime deployments with symlinks

## License

42 School Project
