# Pi Cluster Deployment Guide

## Prerequisites

### Hardware Requirements
- 4x Raspberry Pi 4 (4GB RAM minimum, 8GB recommended)
- 4x MicroSD cards (32GB+, Class 10, A2 rating preferred)
- Network switch (Gigabit recommended)
- 4x USB-C power supplies (3A minimum)
- Ethernet cables

### Software Requirements
- Raspberry Pi OS Lite (64-bit)
- Ansible 2.12+ on control machine
- Python 3.8+ on control machine
- SSH access configured

## Initial Setup

### 1. Prepare Raspberry Pi Images

```bash
# Flash Raspberry Pi OS to SD cards
# Enable SSH and configure WiFi/Ethernet

# For each Pi, create SSH key access
ssh-copy-id pi@192.168.254.121  # pi-lb
ssh-copy-id pi@192.168.254.122  # pi-web1
ssh-copy-id pi@192.168.254.123  # pi-web2
ssh-copy-id pi@192.168.254.124  # pi-db
```

### 2. Network Configuration

Update `/etc/dhcpcd.conf` on each Pi:
```bash
# pi-lb (192.168.254.121)
interface eth0
static ip_address=192.168.254.121/24
static routers=192.168.254.1
static domain_name_servers=8.8.8.8 8.8.4.4

# pi-web1 (192.168.254.122)
interface eth0
static ip_address=192.168.254.122/24
static routers=192.168.254.1
static domain_name_servers=8.8.8.8 8.8.4.4

# pi-web2 (192.168.254.123)
interface eth0
static ip_address=192.168.254.123/24
static routers=192.168.254.1
static domain_name_servers=8.8.8.8 8.8.4.4

# pi-db (192.168.254.124)
interface eth0
static ip_address=192.168.254.124/24
static routers=192.168.254.1
static domain_name_servers=8.8.8.8 8.8.4.4
```

### 3. Basic System Setup

```bash
# Update all systems
ansible all -m apt -a "update_cache=yes upgrade=yes" -b

# Install essential packages
ansible all -m apt -a "name=curl,wget,git,htop,vim state=present" -b

# Configure hostnames
ansible pi-lb -m hostname -a "name=pi-lb" -b
ansible pi-web1 -m hostname -a "name=pi-web1" -b
ansible pi-web2 -m hostname -a "name=pi-web2" -b
ansible pi-db -m hostname -a "name=pi-db" -b
```

## Deployment Steps

### 1. Clone Repository

```bash
git clone <repository-url>
cd pi-cluster-ansible
```

### 2. Configure Inventory

Update `inventories/production/hosts`:
```ini
[load_balancers]
pi-lb ansible_host=192.168.254.121

[web_servers]
pi-web1 ansible_host=192.168.254.122
pi-web2 ansible_host=192.168.254.123

[database_servers]
pi-db ansible_host=192.168.254.124

[all:vars]
ansible_user=pi
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### 3. Configure Variables

Update `group_vars/all.yml`:
```yaml
# Common settings
common_timezone: "America/New_York"
common_app_user: "mpi"

# Database settings
database_mysql_root_password: "secure_root_password"
database_db_name: "webapp_db"
database_db_user: "webapp_user"
database_db_password: "secure_app_password"

# Application settings
webapp_app_port: 3000
webapp_db_host: "192.168.254.124"

# Nginx settings
nginx_app_port: 3000
```

### 4. Install Dependencies

```bash
# Install Ansible collections
make install

# Or manually:
ansible-galaxy install -r requirements.yml
```

### 5. Validate Configuration

```bash
# Test connectivity
ansible all -m ping

# Check inventory
ansible-inventory --list

# Validate playbook syntax
ansible-playbook playbooks/site.yml --syntax-check
```

### 6. Deploy Infrastructure

```bash
# Full deployment
make deploy

# Or step-by-step:
ansible-playbook playbooks/site.yml --tags common
ansible-playbook playbooks/site.yml --tags database
ansible-playbook playbooks/site.yml --tags webapp
ansible-playbook playbooks/site.yml --tags nginx
ansible-playbook playbooks/site.yml --tags angular
```

### 7. Validate Deployment

```bash
# Run validation tests
make validate

# Or manually:
ansible-playbook playbooks/validate-cluster.yml
ansible-playbook playbooks/validate-webapp.yml
ansible-playbook playbooks/validate-angular.yml
```

## Post-Deployment Configuration

### 1. SSL/TLS Setup (Optional)

```bash
# Install certbot on load balancer
ansible pi-lb -m apt -a "name=certbot,python3-certbot-nginx" -b

# Generate certificate (replace with your domain)
ansible pi-lb -m shell -a "certbot --nginx -d your-domain.com --non-interactive --agree-tos -m your-email@domain.com" -b
```

### 2. Firewall Configuration

```bash
# Configure UFW on all nodes
ansible all -m ufw -a "rule=allow port=22" -b
ansible load_balancers -m ufw -a "rule=allow port=80" -b
ansible load_balancers -m ufw -a "rule=allow port=443" -b
ansible all -m ufw -a "state=enabled" -b
```

### 3. Monitoring Setup

```bash
# Install monitoring tools
ansible all -m apt -a "name=htop,iotop,nethogs state=present" -b

# Configure log rotation
ansible all -m copy -a "src=files/logrotate.conf dest=/etc/logrotate.d/picluster" -b
```

## Troubleshooting Deployment

### Common Issues

#### SSH Connection Problems
```bash
# Test SSH connectivity
ssh -v pi@192.168.254.121

# Check SSH key authentication
ssh-add -l
ssh-copy-id -i ~/.ssh/id_rsa.pub pi@192.168.254.121
```

#### Ansible Permission Issues
```bash
# Ensure sudo access
ansible all -m shell -a "sudo whoami" -b

# Check Python installation
ansible all -m setup -a "filter=ansible_python*"
```

#### Package Installation Failures
```bash
# Update package cache
ansible all -m apt -a "update_cache=yes" -b

# Fix broken packages
ansible all -m shell -a "apt-get -f install" -b

# Check disk space
ansible all -m shell -a "df -h"
```

#### Database Connection Issues
```bash
# Test database connectivity
ansible pi-db -m shell -a "systemctl status mariadb"

# Check database configuration
ansible pi-db -m shell -a "mysql -u root -p -e 'SHOW DATABASES;'"

# Verify network connectivity
ansible web_servers -m shell -a "telnet 192.168.254.124 3306"
```

### Recovery Procedures

#### Complete Redeployment
```bash
# Clean existing installation
ansible all -m shell -a "systemctl stop nginx mariadb" -b
ansible all -m apt -a "name=nginx,mariadb-server state=absent purge=yes" -b

# Redeploy
ansible-playbook playbooks/site.yml
```

#### Partial Recovery
```bash
# Restart specific services
ansible web_servers -m systemd -a "name=nginx state=restarted" -b
ansible database_servers -m systemd -a "name=mariadb state=restarted" -b

# Redeploy specific components
ansible-playbook playbooks/site.yml --tags webapp --limit web_servers
```

## Performance Optimization

### Database Tuning
```bash
# Optimize MariaDB configuration
ansible pi-db -m template -a "src=templates/my.cnf.j2 dest=/etc/mysql/mariadb.conf.d/99-optimization.cnf" -b
ansible pi-db -m systemd -a "name=mariadb state=restarted" -b
```

### Application Tuning
```bash
# Optimize PM2 configuration
ansible web_servers -m template -a "src=templates/ecosystem.config.js.j2 dest=/opt/webapp/ecosystem.config.js" -b
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi
```

### Network Optimization
```bash
# Optimize network settings
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
sysctl -p
```

## Maintenance Procedures

### Regular Updates
```bash
# System updates (monthly)
ansible all -m apt -a "update_cache=yes upgrade=yes" -b

# Application updates (as needed)
ansible-playbook playbooks/site.yml --tags webapp

# Security updates (weekly)
ansible all -m apt -a "name=* state=latest security=yes" -b
```

### Backup Procedures
```bash
# Database backup
ansible pi-db -m shell -a "mysqldump -u root -p webapp_db > /backup/webapp_$(date +%Y%m%d).sql"

# Configuration backup
tar -czf cluster-backup-$(date +%Y%m%d).tar.gz inventories/ group_vars/ host_vars/
```

### Health Monitoring
```bash
# Automated health checks
crontab -e
# Add: */5 * * * * /path/to/health-check.sh
```

## Scaling Procedures

### Adding Web Servers
```bash
# 1. Prepare new Pi with same network configuration
# 2. Add to inventory
echo "pi-web3 ansible_host=192.168.254.125" >> inventories/production/hosts

# 3. Deploy to new node
ansible-playbook playbooks/site.yml --limit pi-web3

# 4. Update load balancer
ansible-playbook playbooks/site.yml --tags nginx --limit pi-lb
```

### Database Scaling
```bash
# Set up read replicas
ansible-playbook playbooks/database-replica.yml

# Configure application for read/write splitting
# Update application configuration
```

## Security Hardening

### System Security
```bash
# Disable password authentication
ansible all -m lineinfile -a "path=/etc/ssh/sshd_config regexp='^PasswordAuthentication' line='PasswordAuthentication no'" -b

# Configure fail2ban
ansible all -m apt -a "name=fail2ban state=present" -b
ansible all -m systemd -a "name=fail2ban state=started enabled=yes" -b
```

### Application Security
```bash
# Configure HTTPS redirect
ansible load_balancers -m template -a "src=templates/nginx-ssl.conf.j2 dest=/etc/nginx/sites-available/default" -b

# Set up database SSL
ansible database_servers -m template -a "src=templates/mysql-ssl.cnf.j2 dest=/etc/mysql/mariadb.conf.d/ssl.cnf" -b
```

This deployment guide provides comprehensive instructions for setting up and maintaining your Pi cluster in production environments.
