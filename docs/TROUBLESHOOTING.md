# Pi Cluster Troubleshooting Guide

## Quick Diagnostics

### System Health Check
```bash
# Run comprehensive health check
make validate

# Quick service status
ansible all -m shell -a "systemctl is-active nginx mariadb"

# Check cluster connectivity
ansible all -m ping
```

### Dashboard Access Issues
```bash
# Test load balancer
curl -I http://192.168.254.121/

# Test API endpoint
curl http://192.168.254.121/api/health

# Check nginx status
ansible pi-lb -m shell -a "systemctl status nginx"
```

## Common Issues

### 1. Dashboard Not Loading

**Symptoms**: Browser shows connection refused or timeout

**Diagnosis**:
```bash
# Check nginx service
ansible pi-lb -m shell -a "systemctl status nginx"

# Check nginx configuration
ansible pi-lb -m shell -a "nginx -t"

# Check port binding
ansible pi-lb -m shell -a "netstat -tlnp | grep :80"
```

**Solutions**:
```bash
# Restart nginx
ansible pi-lb -m systemd -a "name=nginx state=restarted" -b

# Redeploy nginx configuration
ansible-playbook playbooks/site.yml --tags nginx --limit pi-lb

# Check firewall
ansible pi-lb -m shell -a "ufw status"
```

### 2. API Endpoints Returning 502/503 Errors

**Symptoms**: Dashboard loads but shows "No server responses"

**Diagnosis**:
```bash
# Check backend servers
ansible web_servers -m shell -a "systemctl status nginx"

# Check Node.js applications
ansible web_servers -m shell -a "pm2 list" -b -u mpi

# Test direct backend access
curl http://192.168.254.122:3000/health
curl http://192.168.254.123:3000/health
```

**Solutions**:
```bash
# Restart PM2 processes
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi

# Redeploy applications
ansible-playbook playbooks/site.yml --tags webapp

# Check application logs
ansible web_servers -m shell -a "pm2 logs --lines 50" -b -u mpi
```

### 3. Database Connection Errors

**Symptoms**: API returns "database: disconnected"

**Diagnosis**:
```bash
# Check MariaDB service
ansible pi-db -m shell -a "systemctl status mariadb"

# Test database connectivity
ansible web_servers -m shell -a "telnet 192.168.254.124 3306"

# Check database logs
ansible pi-db -m shell -a "journalctl -u mariadb --since '1 hour ago'"
```

**Solutions**:
```bash
# Restart MariaDB
ansible pi-db -m systemd -a "name=mariadb state=restarted" -b

# Check database configuration
ansible pi-db -m shell -a "mysql -u root -p -e 'SHOW PROCESSLIST;'"

# Verify user permissions
ansible pi-db -m shell -a "mysql -u root -p -e 'SELECT User,Host FROM mysql.user;'"
```

### 4. Load Balancing Not Working

**Symptoms**: All requests go to same server

**Diagnosis**:
```bash
# Test load balancing
for i in {1..10}; do
  curl -s http://192.168.254.121/api/ | jq .server
done

# Check nginx upstream configuration
ansible pi-lb -m shell -a "nginx -T | grep -A 10 upstream"
```

**Solutions**:
```bash
# Redeploy nginx configuration
ansible-playbook playbooks/site.yml --tags nginx --limit pi-lb

# Check backend server health
ansible web_servers -m uri -a "url=http://localhost:3000/health"

# Verify nginx upstream status
ansible pi-lb -m shell -a "curl -s http://localhost/nginx_status"
```

### 5. High Memory Usage

**Symptoms**: System becomes slow or unresponsive

**Diagnosis**:
```bash
# Check memory usage
ansible all -m shell -a "free -h"

# Check process memory
ansible all -m shell -a "ps aux --sort=-%mem | head -10"

# Check PM2 memory usage
ansible web_servers -m shell -a "pm2 monit" -b -u mpi
```

**Solutions**:
```bash
# Restart high-memory processes
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi

# Adjust PM2 memory limits
# Edit ecosystem.config.js: max_memory_restart: '300M'

# Clear system caches
ansible all -m shell -a "sync && echo 3 > /proc/sys/vm/drop_caches" -b
```

## Service-Specific Issues

### nginx Issues

**Configuration Test**:
```bash
# Test configuration syntax
ansible load_balancers -m shell -a "nginx -t"

# Check configuration files
ansible load_balancers -m shell -a "ls -la /etc/nginx/sites-*/"
```

**Log Analysis**:
```bash
# Check access logs
ansible load_balancers -m shell -a "tail -f /var/log/nginx/access.log"

# Check error logs
ansible load_balancers -m shell -a "tail -f /var/log/nginx/error.log"
```

**Common Fixes**:
```bash
# Reload configuration
ansible load_balancers -m shell -a "nginx -s reload" -b

# Full restart
ansible load_balancers -m systemd -a "name=nginx state=restarted" -b
```

### PM2 Issues

**Process Management**:
```bash
# Check PM2 status
ansible web_servers -m shell -a "pm2 list" -b -u mpi

# Check PM2 logs
ansible web_servers -m shell -a "pm2 logs --lines 100" -b -u mpi

# Monitor PM2 processes
ansible web_servers -m shell -a "pm2 monit" -b -u mpi
```

**Common Fixes**:
```bash
# Restart all processes
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi

# Reload PM2 configuration
ansible web_servers -m shell -a "pm2 reload ecosystem.config.js" -b -u mpi

# Reset PM2
ansible web_servers -m shell -a "pm2 kill && pm2 start ecosystem.config.js" -b -u mpi
```

### MariaDB Issues

**Connection Problems**:
```bash
# Check service status
ansible database_servers -m shell -a "systemctl status mariadb"

# Test local connection
ansible database_servers -m shell -a "mysql -u root -p -e 'SELECT 1;'"

# Check network binding
ansible database_servers -m shell -a "netstat -tlnp | grep :3306"
```

**Performance Issues**:
```bash
# Check slow queries
ansible database_servers -m shell -a "mysql -u root -p -e 'SHOW PROCESSLIST;'"

# Check database size
ansible database_servers -m shell -a "mysql -u root -p -e 'SELECT table_schema, ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS \"DB Size in MB\" FROM information_schema.tables GROUP BY table_schema;'"
```

## Network Issues

### Connectivity Problems

**Basic Network Tests**:
```bash
# Test ping between nodes
ansible all -m shell -a "ping -c 3 192.168.254.121"

# Check routing
ansible all -m shell -a "ip route show"

# Test DNS resolution
ansible all -m shell -a "nslookup google.com"
```

**Port Connectivity**:
```bash
# Test specific ports
ansible web_servers -m shell -a "telnet 192.168.254.124 3306"
ansible load_balancers -m shell -a "telnet 192.168.254.122 3000"

# Check listening ports
ansible all -m shell -a "netstat -tlnp"
```

### Firewall Issues

**UFW Status**:
```bash
# Check firewall status
ansible all -m shell -a "ufw status verbose"

# Check iptables rules
ansible all -m shell -a "iptables -L -n"
```

**Common Fixes**:
```bash
# Allow required ports
ansible load_balancers -m ufw -a "rule=allow port=80" -b
ansible web_servers -m ufw -a "rule=allow port=3000 src=192.168.254.121" -b
ansible database_servers -m ufw -a "rule=allow port=3306 src=192.168.254.0/24" -b
```

## Performance Issues

### High CPU Usage

**Diagnosis**:
```bash
# Check CPU usage
ansible all -m shell -a "top -bn1 | head -20"

# Check load average
ansible all -m shell -a "uptime"

# Identify CPU-intensive processes
ansible all -m shell -a "ps aux --sort=-%cpu | head -10"
```

**Solutions**:
```bash
# Restart high-CPU services
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi

# Check for runaway processes
ansible all -m shell -a "kill -9 <PID>" -b
```

### Disk Space Issues

**Diagnosis**:
```bash
# Check disk usage
ansible all -m shell -a "df -h"

# Find large files
ansible all -m shell -a "find / -type f -size +100M 2>/dev/null | head -10"

# Check log file sizes
ansible all -m shell -a "du -sh /var/log/*"
```

**Solutions**:
```bash
# Clean package cache
ansible all -m shell -a "apt-get clean" -b

# Rotate logs
ansible all -m shell -a "logrotate -f /etc/logrotate.conf" -b

# Clean PM2 logs
ansible web_servers -m shell -a "pm2 flush" -b -u mpi
```

## Recovery Procedures

### Service Recovery

**Individual Service Restart**:
```bash
# Restart specific services
ansible load_balancers -m systemd -a "name=nginx state=restarted" -b
ansible database_servers -m systemd -a "name=mariadb state=restarted" -b
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi
```

**Full Service Recovery**:
```bash
# Stop all services
ansible all -m shell -a "systemctl stop nginx mariadb" -b
ansible web_servers -m shell -a "pm2 kill" -b -u mpi

# Start services in order
ansible database_servers -m systemd -a "name=mariadb state=started" -b
ansible web_servers -m shell -a "pm2 start ecosystem.config.js" -b -u mpi
ansible load_balancers -m systemd -a "name=nginx state=started" -b
```

### Node Recovery

**Single Node Replacement**:
```bash
# Prepare new node with same IP
# Deploy to replacement node
ansible-playbook playbooks/site.yml --limit pi-web1

# Verify integration
ansible-playbook playbooks/validate-cluster.yml
```

**Complete Cluster Recovery**:
```bash
# Full redeployment
ansible-playbook playbooks/site.yml

# Restore database from backup
ansible pi-db -m shell -a "mysql -u root -p webapp_db < /backup/latest.sql"
```

## Monitoring and Alerting

### Log Monitoring

**Centralized Log Collection**:
```bash
# Collect logs from all nodes
mkdir -p logs/$(date +%Y%m%d)
ansible all -m fetch -a "src=/var/log/nginx/error.log dest=logs/$(date +%Y%m%d)/"
ansible all -m fetch -a "src=/var/log/syslog dest=logs/$(date +%Y%m%d)/"
```

**Real-time Log Monitoring**:
```bash
# Monitor nginx logs
ansible load_balancers -m shell -a "tail -f /var/log/nginx/access.log"

# Monitor application logs
ansible web_servers -m shell -a "pm2 logs --lines 0" -b -u mpi

# Monitor system logs
ansible all -m shell -a "journalctl -f"
```

### Health Check Automation

**Automated Health Checks**:
```bash
#!/bin/bash
# health-check.sh
echo "=== Pi Cluster Health Check $(date) ==="

# Test dashboard
if curl -s http://192.168.254.121/ > /dev/null; then
    echo "✓ Dashboard accessible"
else
    echo "✗ Dashboard not accessible"
fi

# Test API
if curl -s http://192.168.254.121/api/health | grep -q "healthy"; then
    echo "✓ API healthy"
else
    echo "✗ API not healthy"
fi

# Test database
if ansible pi-db -m shell -a "systemctl is-active mariadb" | grep -q "active"; then
    echo "✓ Database active"
else
    echo "✗ Database not active"
fi
```

### Performance Monitoring

**Resource Usage Monitoring**:
```bash
# Create monitoring script
#!/bin/bash
# monitor.sh
while true; do
    echo "=== $(date) ==="
    ansible all -m shell -a "free -m | grep Mem" | grep -v "SUCCESS"
    ansible all -m shell -a "uptime" | grep -v "SUCCESS"
    sleep 60
done
```

This troubleshooting guide covers the most common issues and provides systematic approaches to diagnosis and resolution.
