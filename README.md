# Pi Cluster Ansible

Production-ready Raspberry Pi cluster with Angular frontend, Node.js backend, and MariaDB database. Fully automated deployment using Ansible with load balancing, monitoring, and high availability.

## 🚀 Quick Start

```bash
# Install dependencies
make install

# Deploy cluster (will prompt for vault password)
make deploy

# Access dashboard
open http://192.168.254.121/
```

## 📋 Architecture

- **Load Balancer**: nginx reverse proxy with Angular dashboard
- **Web Servers**: Node.js applications (2 nodes) with PM2 management
- **Database Server**: MariaDB with optimized configuration
- **Monitoring**: Real-time dashboard with health checks

## 🔧 Prerequisites

- 4x Raspberry Pi 4 (4GB+ RAM recommended)
- Ansible 2.12+ on control machine
- SSH access to all Pi nodes
- Python 3.8+ on target hosts

## 📚 Documentation

### Core Documentation
- **[Project Structure](PROJECT_STRUCTURE.md)** - Complete directory structure overview
- **[Production Guide](docs/PRODUCTION.md)** - Complete production deployment guide
- **[Architecture](docs/ARCHITECTURE.md)** - System architecture and design
- **[Deployment](docs/DEPLOYMENT.md)** - Step-by-step deployment instructions
- **[Vault Usage](docs/VAULT.md)** - Ansible Vault secrets management
- **[Security](docs/SECURITY.md)** - JWT, API keys, and rate limiting
- **[API Documentation](docs/API.md)** - REST API reference
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Operations Runbook](docs/OPERATIONS.md)** - Daily operations and maintenance

### Quick Reference
- **Dashboard**: http://192.168.254.121/
- **API Endpoint**: http://192.168.254.122:3000/api/
- **Health Check**: http://192.168.254.122:3000/health
- **Admin Login**: POST http://192.168.254.122:3000/api/auth/login

## 🏗️ Infrastructure

```
Internet → Load Balancer (pi-lb) → Web Servers (pi-web1, pi-web2) → Database (pi-db)
```

### Network Configuration
```
pi-lb:   192.168.254.121 (Load Balancer + Angular Dashboard)
pi-web1: 192.168.254.122 (Node.js Application Server)
pi-web2: 192.168.254.123 (Node.js Application Server)
pi-db:   192.168.254.124 (MariaDB Database Server)
```

## 🚀 Deployment

### Automated Deployment
```bash
# Install dependencies
make install

# Deploy the cluster (uses vault password file)
make deploy

# Validate deployment
make validate
```

### Manual Deployment
```bash
# Deploy all services (uses vault password file)
ansible-playbook playbooks/site.yml

# Deploy specific components
ansible-playbook playbooks/site.yml --tags database
ansible-playbook playbooks/site.yml --tags webapp
ansible-playbook playbooks/site.yml --tags nginx
ansible-playbook playbooks/site.yml --tags angular
```

## 📊 Features

### Angular Dashboard
- 🎨 Modern responsive UI with real-time updates
- 📊 Load balancing visualization
- 🟢 Server health monitoring
- 🔄 Auto-refresh every 10 seconds
- 📱 Mobile-friendly design
- 🎯 Interactive server status cards

### Backend Services
- ⚡ Node.js Express applications with PM2
- 🔄 Automatic failover and restart
- 📈 Performance monitoring
- 🗄️ Database connection pooling
- 🔒 JWT authentication with 1-hour expiration
- 🔑 API key protection for endpoints
- 🛡️ Rate limiting (100 req/15min, 5 auth/15min)
- 🏥 Health check endpoints

### Infrastructure
- 🌐 nginx load balancing with health checks
- 🗃️ MariaDB with SSD optimization
- 🔧 Automated deployment and configuration
- 📋 Comprehensive monitoring and logging
- 🛡️ Security hardening and firewall rules
- 🎭 Modular Ansible role architecture

## 🔍 Monitoring

### Health Checks
```bash
# Validate deployment
make validate

# Comprehensive cluster validation
ansible-playbook playbooks/validate-cluster.yml

# Web application validation
ansible-playbook playbooks/validate-webapp.yml

# Angular dashboard validation
ansible-playbook playbooks/validate-angular.yml
```

### Dashboard Features
- Real-time server status display
- Load balancing request distribution
- Database connectivity monitoring
- Performance metrics visualization
- Auto-refresh functionality

## 🛠️ Maintenance

### Updates
```bash
# System updates
ansible all -m apt -a "upgrade=safe" -b

# Application updates
ansible-playbook playbooks/site.yml --tags webapp

# Configuration updates
ansible-playbook playbooks/site.yml
```

### Backup
```bash
# Database backup
ansible pi-db -m shell -a "mysqldump -u root -p webapp_db > /backup/webapp_$(date +%Y%m%d).sql"

# Configuration backup
tar -czf cluster-config-$(date +%Y%m%d).tar.gz inventories/ group_vars/
```

## 🔧 Configuration

### Global Settings
Edit variables in:
- `group_vars/all.yml` - Global cluster settings
- `group_vars/all/vault.yml` - Encrypted secrets (use ansible-vault)
- `group_vars/[group].yml` - Group-specific settings
- `host_vars/[host].yml` - Host-specific settings

### Key Configuration Files
```
inventories/production/hosts     # Server inventory
group_vars/all.yml              # Global variables
group_vars/all/vault.yml        # Encrypted secrets
roles/*/defaults/main.yml       # Role-specific defaults
```

## 🚨 Troubleshooting

### Quick Diagnostics
```bash
# System health check
make validate

# Service status
ansible all -m shell -a "systemctl status nginx mariadb"

# Application logs
ansible web_servers -m shell -a "pm2 logs --lines 50" -b -u mpi
```

### Common Issues
- **Dashboard not loading**: Check nginx service and firewall
- **API errors**: Verify backend services and database connectivity
- **Load balancing issues**: Check upstream server health
- **Database errors**: Verify MariaDB service and user permissions

See [Troubleshooting Guide](docs/TROUBLESHOOTING.md) for detailed solutions.

## 📈 Performance

### Current Metrics
- **Response Time**: < 50ms average
- **Throughput**: 1000+ requests/second
- **Memory Usage**: ~60MB per Node.js process
- **Availability**: 99.9% target with automatic failover

### Optimization
- PM2 cluster mode for multi-core utilization
- nginx caching for static assets
- MariaDB query optimization
- Connection pooling for database efficiency

## 🔒 Security

### Implemented Security
- **Ansible Vault**: Encrypted secrets management
- **SSH Key Authentication**: No password-based access
- **Host Key Verification**: Enabled for all connections
- **Firewall Rules**: UFW configuration
- **Database Isolation**: Dedicated user with limited privileges
- **Security Headers**: Implemented via nginx
- **Input Validation**: Backend sanitization

### Secrets Management
```bash
# Edit encrypted secrets
ansible-vault edit group_vars/all/vault.yml

# View vault contents
ansible-vault view group_vars/all/vault.yml

# Change vault password
ansible-vault rekey group_vars/all/vault.yml
```

### Production Recommendations
- SSL/TLS certificates (Let's Encrypt)
- VPN access for management
- Regular security updates
- Intrusion detection system
- Backup encryption

## 📦 Roles

- `common`: Base system configuration and user setup
- `database`: MariaDB installation and optimization
- `nodejs`: Node.js runtime and PM2 process manager
- `webapp`: Full-stack application deployment with Angular source
- `nginx`: Load balancer and reverse proxy setup
- `angular`: Frontend dashboard deployment

## 🎯 Quality Assurance

### Code Quality
- **Ansible Lint**: 0 violations (production-ready)
- **FQCN Compliance**: All modules use fully qualified names
- **Variable Naming**: Consistent role-prefixed conventions
- **Security Standards**: Industry best practices implemented
- **Secrets Management**: Encrypted with Ansible Vault

### Testing & Validation
- **5 validation playbooks** for comprehensive testing
- **Health check endpoints** for monitoring
- **Load balancing tests** for distribution verification
- **Database connectivity** validation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes thoroughly
4. Update documentation
5. Submit a pull request

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [docs/](docs/) directory
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions

---

**Built with ❤️ for the Raspberry Pi community**
