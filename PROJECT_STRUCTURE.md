# Pi Cluster Ansible - Project Structure

## Overview
Production-ready Raspberry Pi cluster with Angular frontend, Node.js backend, and MariaDB database. Fully automated deployment using Ansible with load balancing, monitoring, and high availability.

## Directory Structure

```
pi-cluster-ansible/
├── README.md                           # Main project documentation
├── PROJECT_STRUCTURE.md               # This file - project structure overview
├── LICENSE                            # MIT license
├── .gitignore                         # Git ignore patterns
├── .ansible-lint                      # Ansible linting configuration
├── ansible.cfg                        # Ansible configuration
├── requirements.yml                   # Ansible Galaxy dependencies
├── Makefile                          # Build automation commands
├── deploy.sh                         # Main deployment script
├── update.sh                         # System update script
│
├── docs/                             # 📚 Documentation
│   ├── PRODUCTION.md                 # Production deployment guide
│   ├── ARCHITECTURE.md               # System architecture documentation
│   ├── DEPLOYMENT.md                 # Step-by-step deployment guide
│   ├── API.md                        # REST API documentation
│   ├── TROUBLESHOOTING.md            # Common issues and solutions
│   └── OPERATIONS.md                 # Daily operations runbook
│
├── inventories/                      # 🏗️ Infrastructure Configuration
│   └── production/
│       └── hosts                     # Production server inventory
│
├── group_vars/                       # 🔧 Group Variables
│   ├── all.yml                      # Global cluster settings
│   ├── database_servers.yml         # Database-specific variables
│   └── web_servers.yml              # Web server variables
│
├── host_vars/                        # 🖥️ Host-Specific Variables
│   └── (individual host configs)
│
├── roles/                            # 🎭 Ansible Roles
│   ├── common/                       # Base system configuration
│   │   ├── defaults/main.yml         # Default variables
│   │   ├── tasks/main.yml            # Common setup tasks
│   │   ├── handlers/main.yml         # Service handlers
│   │   ├── meta/main.yml             # Role metadata
│   │   ├── templates/                # Configuration templates
│   │   ├── files/                    # Static files
│   │   └── vars/                     # Role variables
│   │
│   ├── database/                     # MariaDB database server
│   │   ├── defaults/main.yml         # Database defaults
│   │   ├── tasks/main.yml            # Database installation/config
│   │   ├── handlers/main.yml         # Database service handlers
│   │   ├── templates/
│   │   │   ├── my.cnf.j2             # MariaDB configuration
│   │   │   └── ssd-optimization.cnf.j2  # SSD optimizations
│   │   ├── meta/main.yml             # Role dependencies
│   │   ├── files/                    # Database files
│   │   └── vars/                     # Database variables
│   │
│   ├── nodejs/                       # Node.js runtime
│   │   ├── defaults/main.yml         # Node.js defaults
│   │   ├── tasks/main.yml            # Node.js installation
│   │   ├── handlers/main.yml         # Node.js handlers
│   │   ├── meta/main.yml             # Role metadata
│   │   ├── templates/                # Node.js templates
│   │   ├── files/                    # Node.js files
│   │   └── vars/                     # Node.js variables
│   │
│   ├── webapp/                       # Web application deployment
│   │   ├── defaults/main.yml         # Application defaults
│   │   ├── tasks/main.yml            # Application deployment
│   │   ├── handlers/main.yml         # Application handlers
│   │   ├── templates/
│   │   │   ├── ecosystem.config.js.j2   # PM2 configuration
│   │   │   └── .env.j2               # Environment variables
│   │   ├── files/
│   │   │   ├── app.js                # Node.js application
│   │   │   ├── package.json          # NPM dependencies
│   │   │   └── angular-app/          # Angular source files
│   │   │       ├── package.json      # Angular dependencies
│   │   │       ├── angular.json      # Angular configuration
│   │   │       ├── tsconfig.json     # TypeScript configuration
│   │   │       ├── tsconfig.app.json # App TypeScript config
│   │   │       └── src/              # Angular source code
│   │   │           ├── index.html    # Main HTML template
│   │   │           ├── main.ts       # Angular bootstrap
│   │   │           ├── polyfills.ts  # Browser polyfills
│   │   │           ├── styles.css    # Global styles
│   │   │           └── app/          # Angular components
│   │   │               ├── app.module.ts     # App module
│   │   │               ├── app.component.ts  # Main component
│   │   │               └── app.component.html # Component template
│   │   ├── meta/main.yml             # Role dependencies
│   │   └── vars/                     # Application variables
│   │
│   ├── nginx/                        # Load balancer & reverse proxy
│   │   ├── defaults/main.yml         # Nginx defaults
│   │   ├── tasks/main.yml            # Nginx installation/config
│   │   ├── handlers/main.yml         # Nginx service handlers
│   │   ├── templates/
│   │   │   └── nginx.conf.j2         # Nginx configuration
│   │   ├── meta/main.yml             # Role metadata
│   │   ├── files/                    # Nginx files
│   │   └── vars/                     # Nginx variables
│   │
│   └── angular/                      # Frontend dashboard deployment
│       ├── defaults/main.yml         # Angular defaults
│       ├── tasks/main.yml            # Angular deployment
│       └── meta/main.yml             # Role metadata
│
├── playbooks/                        # 🎬 Ansible Playbooks
│   ├── site.yml                      # Main deployment playbook
│   ├── validate.yml                  # Basic validation
│   ├── validate-cluster.yml          # Comprehensive cluster validation
│   ├── validate-webapp.yml           # Web application validation
│   └── validate-angular.yml          # Angular dashboard validation
│
├── logs/                             # 📋 Log Files
│   └── ansible.log                   # Ansible execution logs
│
├── files/                            # 📁 Global Files
│   └── (shared files across roles)
│
├── templates/                        # 📄 Global Templates
│   └── (shared templates across roles)
│
├── .ansible/                         # 🔧 Ansible Cache
│   ├── collections/                  # Downloaded collections
│   ├── roles/                        # Downloaded roles
│   └── modules/                      # Custom modules
│
├── .git/                             # 🗂️ Git Repository
│   └── (git version control files)
│
└── scripts/                          # 🛠️ Utility Scripts
    ├── fix_lint.sh                   # Linting fixes
    ├── fix_remaining_lint.sh         # Additional lint fixes
    └── fix_final_lint.sh             # Final lint cleanup
```

## Key Components

### 🏗️ Infrastructure
- **4 Raspberry Pi nodes** in production cluster
- **Load balancer** (pi-lb): nginx + Angular dashboard
- **Web servers** (pi-web1, pi-web2): Node.js + PM2
- **Database** (pi-db): MariaDB with optimizations

### 🎭 Ansible Roles
- **common**: Base system setup, users, packages
- **database**: MariaDB installation and configuration
- **nodejs**: Node.js runtime and PM2 process manager
- **webapp**: Application deployment with real Node.js app
- **nginx**: Load balancer and reverse proxy
- **angular**: Frontend dashboard deployment

### 📚 Documentation
- **Production-ready guides** for deployment and operations
- **API documentation** with examples
- **Architecture diagrams** and system design
- **Troubleshooting guides** with solutions
- **Operations runbooks** for daily maintenance

### 🔧 Configuration Management
- **Inventory-based** server management
- **Group and host variables** for customization
- **Template-driven** configuration files
- **Environment-specific** settings

### 🚀 Deployment Features
- **One-command deployment**: `make deploy`
- **Automated validation**: Health checks and testing
- **Load balancing**: nginx round-robin distribution
- **Process management**: PM2 with auto-restart
- **Real-time monitoring**: Angular dashboard
- **Database optimization**: SSD-specific tuning

### 📊 Monitoring & Validation
- **Health check endpoints**: `/health` and `/api/`
- **Load balancing tests**: Multi-request validation
- **Service status monitoring**: systemd service checks
- **Real-time dashboard**: Auto-refreshing Angular UI
- **Comprehensive logging**: Centralized log management

## Quick Commands

```bash
# Deploy entire cluster
make deploy

# Validate deployment
make validate

# Install dependencies
make install

# Run linting
make lint

# View logs
tail -f logs/ansible.log

# Test specific components
ansible-playbook playbooks/validate-webapp.yml
ansible-playbook playbooks/validate-angular.yml
```

## Network Architecture

```
Internet → Load Balancer (192.168.254.121) → Web Servers → Database
           pi-lb                              pi-web1/2    pi-db
           nginx + Angular                    Node.js      MariaDB
```

## Technology Stack

- **Infrastructure**: Raspberry Pi 4 cluster
- **Automation**: Ansible with production-grade roles
- **Frontend**: Angular dashboard with real-time monitoring
- **Backend**: Node.js/Express with PM2 process management
- **Database**: MariaDB with SSD optimizations
- **Load Balancer**: nginx with health checks
- **Monitoring**: Custom dashboard with API integration

This structure provides a complete, production-ready Pi cluster with professional documentation, automated deployment, and comprehensive monitoring capabilities.
