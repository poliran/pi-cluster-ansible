# Pi Cluster Production Documentation

## Overview

Production-ready Raspberry Pi cluster with Angular frontend, Node.js backend, and MariaDB database. Fully automated deployment using Ansible with load balancing, monitoring, and high availability.

## Architecture

```
Internet → Load Balancer (pi-lb) → Web Servers (pi-web1, pi-web2) → Database (pi-db)
```

### Components
- **Load Balancer**: nginx reverse proxy with Angular dashboard
- **Web Servers**: Node.js applications with PM2 process management
- **Database**: MariaDB with optimized configuration
- **Monitoring**: Real-time dashboard with health checks

## Quick Start

```bash
# Clone and deploy
git clone <repository>
cd pi-cluster-ansible

# Install dependencies
make install

# Deploy cluster
make deploy

# Validate deployment
make validate
```

## Access Points

- **Dashboard**: http://192.168.254.121/
- **API**: http://192.168.254.121/api/
- **Health Check**: http://192.168.254.121/api/health

## Infrastructure

### Hardware Requirements
- 4x Raspberry Pi 4 (4GB+ RAM recommended)
- MicroSD cards (32GB+ Class 10)
- Network switch with Gigabit ports
- Power supplies (USB-C, 3A minimum)

### Network Configuration
```
pi-lb:   192.168.254.121 (Load Balancer)
pi-web1: 192.168.254.122 (Web Server)
pi-web2: 192.168.254.123 (Web Server)
pi-db:   192.168.254.124 (Database)
```

## Deployment

### Prerequisites
- Ansible 2.12+
- SSH key access to all nodes
- Python 3.8+ on control machine

### Automated Deployment
```bash
# Full deployment
ansible-playbook playbooks/site.yml

# Component-specific deployment
ansible-playbook playbooks/site.yml --tags database
ansible-playbook playbooks/site.yml --tags webapp
ansible-playbook playbooks/site.yml --tags nginx
```

### Manual Verification
```bash
# Check services
ansible all -m service_facts
ansible all -m shell -a "systemctl status nginx mariadb"

# Test connectivity
ansible-playbook playbooks/validate-cluster.yml
```

## Monitoring & Health Checks

### Dashboard Features
- Real-time server status
- Load balancing visualization
- Database connectivity monitoring
- Auto-refresh every 10 seconds
- Responsive design

### Health Endpoints
```bash
# Application health
curl http://192.168.254.121/api/health

# Individual servers
curl http://192.168.254.122:3000/health
curl http://192.168.254.123:3000/health
```

### Service Status
```bash
# Check PM2 processes
ansible web_servers -m shell -a "pm2 list" -b -u mpi

# Check nginx status
ansible load_balancers -m shell -a "nginx -t && systemctl status nginx"

# Check database
ansible database_servers -m shell -a "systemctl status mariadb"
```

## Maintenance

### Updates
```bash
# System updates
ansible-playbook playbooks/update.yml

# Application updates
ansible-playbook playbooks/site.yml --tags webapp

# Restart services
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi
```

### Backup
```bash
# Database backup
ansible pi-db -m shell -a "mysqldump -u root -p webapp_db > /backup/webapp_$(date +%Y%m%d).sql"

# Configuration backup
tar -czf cluster-config-$(date +%Y%m%d).tar.gz inventories/ group_vars/ host_vars/
```

### Log Management
```bash
# Application logs
ansible web_servers -m shell -a "pm2 logs --lines 100" -b -u mpi

# Nginx logs
ansible load_balancers -m shell -a "tail -f /var/log/nginx/access.log"

# System logs
ansible all -m shell -a "journalctl -u nginx -u mariadb --since '1 hour ago'"
```

## Security

### Firewall Configuration
```bash
# Load balancer
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp

# Web servers
ufw allow from 192.168.254.121 to any port 3000
ufw allow 22/tcp

# Database
ufw allow from 192.168.254.0/24 to any port 3306
ufw allow 22/tcp
```

### SSL/TLS Setup
```bash
# Install certbot
ansible load_balancers -m apt -a "name=certbot,python3-certbot-nginx"

# Generate certificates
ansible pi-lb -m shell -a "certbot --nginx -d your-domain.com"
```

### Database Security
- Root password configured
- Application-specific user with limited privileges
- Network access restricted to cluster nodes
- Regular security updates applied

## Troubleshooting

### Common Issues

#### Service Not Starting
```bash
# Check service status
systemctl status nginx mariadb

# Check logs
journalctl -u nginx -f
journalctl -u mariadb -f

# Check PM2 processes
pm2 list
pm2 logs
```

#### Database Connection Issues
```bash
# Test database connectivity
mysql -h 192.168.254.124 -u webapp_user -p webapp_db

# Check MariaDB configuration
cat /etc/mysql/mariadb.conf.d/50-server.cnf
```

#### Load Balancer Issues
```bash
# Test nginx configuration
nginx -t

# Check upstream servers
curl -I http://192.168.254.122:3000/
curl -I http://192.168.254.123:3000/
```

### Performance Tuning

#### Database Optimization
```sql
-- Check slow queries
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';

-- Monitor connections
SHOW PROCESSLIST;
SHOW STATUS LIKE 'Threads_connected';
```

#### Application Performance
```bash
# Monitor PM2 processes
pm2 monit

# Check memory usage
free -h
htop
```

#### Network Performance
```bash
# Test bandwidth between nodes
iperf3 -s  # On target
iperf3 -c 192.168.254.124  # From source
```

## Scaling

### Horizontal Scaling
```bash
# Add new web server
# 1. Update inventory
echo "pi-web3 ansible_host=192.168.254.125" >> inventories/production/hosts

# 2. Deploy to new node
ansible-playbook playbooks/site.yml --limit pi-web3

# 3. Update load balancer configuration
ansible-playbook playbooks/site.yml --tags nginx --limit pi-lb
```

### Vertical Scaling
- Upgrade to Pi 4 8GB models
- Use faster MicroSD cards (A2 rating)
- Add USB 3.0 SSD storage for database

## Backup & Recovery

### Automated Backups
```bash
# Database backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u root -p$DB_PASSWORD webapp_db > /backup/webapp_$DATE.sql
find /backup -name "webapp_*.sql" -mtime +7 -delete
```

### Disaster Recovery
```bash
# Restore database
mysql -u root -p webapp_db < /backup/webapp_20241225_120000.sql

# Redeploy cluster
ansible-playbook playbooks/site.yml

# Validate services
ansible-playbook playbooks/validate-cluster.yml
```

## Monitoring & Alerting

### Prometheus Integration
```yaml
# Add to docker-compose.yml
prometheus:
  image: prom/prometheus
  ports:
    - "9090:9090"
  volumes:
    - ./prometheus.yml:/etc/prometheus/prometheus.yml
```

### Grafana Dashboard
```yaml
grafana:
  image: grafana/grafana
  ports:
    - "3001:3000"
  environment:
    - GF_SECURITY_ADMIN_PASSWORD=admin
```

## Support

### Log Collection
```bash
# Collect all logs
./scripts/collect-logs.sh

# Generate support bundle
tar -czf support-$(date +%Y%m%d).tar.gz logs/ configs/ inventories/
```

### Health Check Script
```bash
#!/bin/bash
echo "=== Pi Cluster Health Check ==="
ansible all -m ping
ansible-playbook playbooks/validate-cluster.yml
curl -s http://192.168.254.121/api/health | jq
```

## License

MIT License - See LICENSE file for details.

## Contributing

1. Fork the repository
2. Create feature branch
3. Test changes thoroughly
4. Submit pull request with documentation updates
