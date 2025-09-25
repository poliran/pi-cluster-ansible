# Pi Cluster Ansible

Production-ready Raspberry Pi cluster with Angular frontend, Node.js backend, and MariaDB database. Fully automated deployment using Ansible with load balancing, monitoring, and high availability.

## 🚀 Quick Start

```bash
# Deploy cluster
make install && make deploy

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
- **[Production Guide](docs/PRODUCTION.md)** - Complete production deployment guide
- **[Architecture](docs/ARCHITECTURE.md)** - System architecture and design
- **[Deployment](docs/DEPLOYMENT.md)** - Step-by-step deployment instructions
- **[API Documentation](docs/API.md)** - REST API reference
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

### Quick Reference
- **Dashboard**: http://192.168.254.121/
- **API Endpoint**: http://192.168.254.121/api/
- **Health Check**: http://192.168.254.121/api/health

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
ansible-galaxy install -r requirements.yml

# Update inventory with your Pi IP addresses
vi inventories/production/hosts

# Deploy the cluster
./deploy.sh
```

### Manual Deployment
```bash
# Deploy all services
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

### Backend Services
- ⚡ Node.js Express applications with PM2
- 🔄 Automatic failover and restart
- 📈 Performance monitoring
- 🗄️ Database connection pooling
- 🔒 Security headers and validation

### Infrastructure
- 🌐 nginx load balancing with health checks
- 🗃️ MariaDB with SSD optimization
- 🔧 Automated deployment and configuration
- 📋 Comprehensive monitoring and logging
- 🛡️ Security hardening and firewall rules

## 🔍 Monitoring

### Health Checks
```bash
# Validate deployment
make validate

# Check individual services
ansible all -m service_facts
ansible-playbook playbooks/validate-cluster.yml
```

### Dashboard Features
- Real-time server status display
- Load balancing request distribution
- Database connectivity monitoring
- Performance metrics visualization

## 🛠️ Maintenance

### Updates
```bash
# System updates
./update.sh

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
- `group_vars/[group].yml` - Group-specific settings
- `host_vars/[host].yml` - Host-specific settings

### Key Configuration Files
```
inventories/production/hosts     # Server inventory
group_vars/all.yml              # Global variables
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
- SSH key-based authentication
- Firewall rules (UFW)
- Database user isolation
- Security headers via nginx
- Input validation and sanitization

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
- `webapp`: Application deployment and configuration
- `nginx`: Load balancer and reverse proxy setup
- `angular`: Frontend dashboard deployment

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
