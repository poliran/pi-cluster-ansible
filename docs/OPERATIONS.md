# Pi Cluster Operations Runbook

## Daily Operations

### Morning Health Check
```bash
#!/bin/bash
# daily-health-check.sh
echo "=== Pi Cluster Daily Health Check $(date) ==="

# 1. System connectivity
echo "Checking system connectivity..."
ansible all -m ping

# 2. Service status
echo "Checking critical services..."
ansible all -m shell -a "systemctl is-active nginx mariadb" | grep -E "(SUCCESS|FAILED)"

# 3. Dashboard accessibility
echo "Testing dashboard..."
if curl -s http://192.168.254.121/ > /dev/null; then
    echo "✓ Dashboard accessible"
else
    echo "✗ Dashboard not accessible - ALERT"
fi

# 4. API health
echo "Testing API endpoints..."
curl -s http://192.168.254.121/api/health | jq

# 5. Load balancing test
echo "Testing load balancing..."
for i in {1..5}; do
    curl -s http://192.168.254.121/api/ | jq -r .server
done | sort | uniq -c

# 6. Resource usage
echo "Checking resource usage..."
ansible all -m shell -a "free -m | grep Mem" | grep -v SUCCESS
ansible all -m shell -a "df -h /" | grep -v SUCCESS

echo "=== Health check complete ==="
```

### Performance Monitoring
```bash
# Check application performance
ansible web_servers -m shell -a "pm2 monit" -b -u mpi

# Monitor database performance
ansible pi-db -m shell -a "mysql -u root -p -e 'SHOW PROCESSLIST;'"

# Check network performance
ansible all -m shell -a "iftop -t -s 10"
```

## Weekly Operations

### System Updates
```bash
#!/bin/bash
# weekly-updates.sh
echo "=== Weekly System Updates $(date) ==="

# 1. Update package cache
ansible all -m apt -a "update_cache=yes" -b

# 2. List available updates
ansible all -m shell -a "apt list --upgradable" -b

# 3. Apply security updates
ansible all -m apt -a "upgrade=safe" -b

# 4. Clean package cache
ansible all -m apt -a "autoclean=yes" -b

# 5. Restart services if needed
ansible all -m shell -a "if [ -f /var/run/reboot-required ]; then echo 'Reboot required'; fi"

echo "=== Updates complete ==="
```

### Log Rotation and Cleanup
```bash
# Rotate logs
ansible all -m shell -a "logrotate -f /etc/logrotate.conf" -b

# Clean PM2 logs
ansible web_servers -m shell -a "pm2 flush" -b -u mpi

# Clean old backup files
ansible pi-db -m shell -a "find /backup -name '*.sql' -mtime +30 -delete"
```

## Monthly Operations

### Database Maintenance
```bash
#!/bin/bash
# monthly-db-maintenance.sh
echo "=== Monthly Database Maintenance $(date) ==="

# 1. Database backup
DATE=$(date +%Y%m%d)
ansible pi-db -m shell -a "mysqldump -u root -p webapp_db > /backup/monthly_$DATE.sql"

# 2. Optimize tables
ansible pi-db -m shell -a "mysql -u root -p -e 'OPTIMIZE TABLE webapp_db.*'"

# 3. Check database integrity
ansible pi-db -m shell -a "mysql -u root -p -e 'CHECK TABLE webapp_db.*'"

# 4. Update statistics
ansible pi-db -m shell -a "mysql -u root -p -e 'ANALYZE TABLE webapp_db.*'"

# 5. Clean old logs
ansible pi-db -m shell -a "mysql -u root -p -e 'PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY)'"

echo "=== Database maintenance complete ==="
```

### Security Updates
```bash
# Apply all security updates
ansible all -m apt -a "upgrade=full" -b

# Update SSL certificates (if using Let's Encrypt)
ansible pi-lb -m shell -a "certbot renew --dry-run" -b

# Review firewall rules
ansible all -m shell -a "ufw status verbose"
```

## Incident Response

### Service Down Procedures

#### Dashboard Not Accessible
```bash
# 1. Check nginx service
ansible pi-lb -m shell -a "systemctl status nginx"

# 2. Check nginx configuration
ansible pi-lb -m shell -a "nginx -t"

# 3. Check nginx logs
ansible pi-lb -m shell -a "tail -50 /var/log/nginx/error.log"

# 4. Restart nginx if needed
ansible pi-lb -m systemd -a "name=nginx state=restarted" -b

# 5. Verify fix
curl -I http://192.168.254.121/
```

#### API Endpoints Down
```bash
# 1. Check backend servers
ansible web_servers -m shell -a "pm2 list" -b -u mpi

# 2. Check application logs
ansible web_servers -m shell -a "pm2 logs --lines 100" -b -u mpi

# 3. Test direct backend access
curl http://192.168.254.122:3000/health
curl http://192.168.254.123:3000/health

# 4. Restart applications
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi

# 5. Verify load balancer can reach backends
ansible pi-lb -m shell -a "curl -I http://192.168.254.122:3000/"
```

#### Database Connection Issues
```bash
# 1. Check MariaDB service
ansible pi-db -m shell -a "systemctl status mariadb"

# 2. Check database logs
ansible pi-db -m shell -a "journalctl -u mariadb --since '1 hour ago'"

# 3. Test database connectivity
ansible web_servers -m shell -a "telnet 192.168.254.124 3306"

# 4. Check database processes
ansible pi-db -m shell -a "mysql -u root -p -e 'SHOW PROCESSLIST;'"

# 5. Restart MariaDB if needed
ansible pi-db -m systemd -a "name=mariadb state=restarted" -b
```

### Performance Issues

#### High CPU Usage
```bash
# 1. Identify high CPU processes
ansible all -m shell -a "ps aux --sort=-%cpu | head -10"

# 2. Check system load
ansible all -m shell -a "uptime"

# 3. Monitor PM2 processes
ansible web_servers -m shell -a "pm2 monit" -b -u mpi

# 4. Restart high-CPU applications
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi
```

#### High Memory Usage
```bash
# 1. Check memory usage
ansible all -m shell -a "free -h"

# 2. Identify memory-intensive processes
ansible all -m shell -a "ps aux --sort=-%mem | head -10"

# 3. Check for memory leaks
ansible web_servers -m shell -a "pm2 logs | grep -i 'memory\|heap'"

# 4. Restart applications with memory limits
ansible web_servers -m shell -a "pm2 restart all" -b -u mpi
```

#### Disk Space Issues
```bash
# 1. Check disk usage
ansible all -m shell -a "df -h"

# 2. Find large files
ansible all -m shell -a "find /var/log -type f -size +100M"

# 3. Clean logs
ansible all -m shell -a "journalctl --vacuum-time=7d" -b

# 4. Clean package cache
ansible all -m shell -a "apt-get clean" -b
```

## Backup and Recovery

### Automated Backup Script
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"

echo "=== Starting backup $(date) ==="

# 1. Database backup
echo "Backing up database..."
ansible pi-db -m shell -a "mysqldump -u root -p webapp_db > $BACKUP_DIR/webapp_$DATE.sql"

# 2. Configuration backup
echo "Backing up configurations..."
tar -czf cluster-config-$DATE.tar.gz inventories/ group_vars/ host_vars/

# 3. Application backup
echo "Backing up applications..."
ansible web_servers -m archive -a "path=/opt/webapp dest=/tmp/webapp-$DATE.tar.gz" -b

# 4. Verify backups
echo "Verifying backups..."
ansible pi-db -m shell -a "ls -la $BACKUP_DIR/webapp_$DATE.sql"

# 5. Clean old backups (keep 30 days)
ansible pi-db -m shell -a "find $BACKUP_DIR -name '*.sql' -mtime +30 -delete"

echo "=== Backup complete ==="
```

### Recovery Procedures

#### Database Recovery
```bash
# 1. Stop applications
ansible web_servers -m shell -a "pm2 stop all" -b -u mpi

# 2. Restore database
ansible pi-db -m shell -a "mysql -u root -p webapp_db < /backup/webapp_YYYYMMDD.sql"

# 3. Verify restoration
ansible pi-db -m shell -a "mysql -u root -p -e 'SELECT COUNT(*) FROM webapp_db.users;'"

# 4. Start applications
ansible web_servers -m shell -a "pm2 start all" -b -u mpi
```

#### Full System Recovery
```bash
# 1. Prepare replacement hardware
# 2. Install base OS
# 3. Configure network settings
# 4. Deploy cluster
ansible-playbook playbooks/site.yml

# 5. Restore data
ansible pi-db -m shell -a "mysql -u root -p webapp_db < /backup/latest.sql"

# 6. Validate deployment
ansible-playbook playbooks/validate-cluster.yml
```

## Scaling Operations

### Adding Web Server
```bash
# 1. Prepare new Pi (pi-web3)
# 2. Update inventory
echo "pi-web3 ansible_host=192.168.254.125" >> inventories/production/hosts

# 3. Deploy to new node
ansible-playbook playbooks/site.yml --limit pi-web3

# 4. Update load balancer
ansible-playbook playbooks/site.yml --tags nginx --limit pi-lb

# 5. Verify load balancing
for i in {1..10}; do
  curl -s http://192.168.254.121/api/ | jq -r .server
done | sort | uniq -c
```

### Database Scaling (Read Replica)
```bash
# 1. Prepare replica server
# 2. Configure master-slave replication
ansible pi-db -m shell -a "mysql -u root -p -e 'GRANT REPLICATION SLAVE ON *.* TO \"replica\"@\"%\" IDENTIFIED BY \"replica_password\";'"

# 3. Create replica
ansible pi-db-replica -m shell -a "mysql -u root -p -e 'CHANGE MASTER TO MASTER_HOST=\"192.168.254.124\", MASTER_USER=\"replica\", MASTER_PASSWORD=\"replica_password\";'"

# 4. Start replication
ansible pi-db-replica -m shell -a "mysql -u root -p -e 'START SLAVE;'"
```

## Monitoring and Alerting

### Custom Monitoring Script
```bash
#!/bin/bash
# monitor.sh
ALERT_EMAIL="admin@example.com"
THRESHOLD_CPU=80
THRESHOLD_MEM=80
THRESHOLD_DISK=90

# Check CPU usage
CPU_USAGE=$(ansible all -m shell -a "top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d'%' -f1" | grep -v SUCCESS | head -1)
if (( $(echo "$CPU_USAGE > $THRESHOLD_CPU" | bc -l) )); then
    echo "ALERT: High CPU usage: $CPU_USAGE%" | mail -s "Pi Cluster Alert" $ALERT_EMAIL
fi

# Check memory usage
MEM_USAGE=$(ansible all -m shell -a "free | grep Mem | awk '{printf \"%.0f\", \$3/\$2 * 100.0}'" | grep -v SUCCESS | head -1)
if (( MEM_USAGE > THRESHOLD_MEM )); then
    echo "ALERT: High memory usage: $MEM_USAGE%" | mail -s "Pi Cluster Alert" $ALERT_EMAIL
fi

# Check disk usage
DISK_USAGE=$(ansible all -m shell -a "df / | tail -1 | awk '{print \$5}' | cut -d'%' -f1" | grep -v SUCCESS | head -1)
if (( DISK_USAGE > THRESHOLD_DISK )); then
    echo "ALERT: High disk usage: $DISK_USAGE%" | mail -s "Pi Cluster Alert" $ALERT_EMAIL
fi
```

### Log Monitoring
```bash
# Monitor for errors in real-time
ansible all -m shell -a "journalctl -f | grep -i error" &

# Monitor application logs
ansible web_servers -m shell -a "pm2 logs --lines 0" -b -u mpi &

# Monitor nginx access logs
ansible pi-lb -m shell -a "tail -f /var/log/nginx/access.log" &
```

## Maintenance Windows

### Planned Maintenance Procedure
```bash
#!/bin/bash
# maintenance-window.sh
echo "=== Starting maintenance window $(date) ==="

# 1. Notify users (update dashboard)
echo "Maintenance mode activated"

# 2. Stop accepting new connections
ansible pi-lb -m shell -a "nginx -s quit" -b

# 3. Wait for existing connections to finish
sleep 30

# 4. Stop applications
ansible web_servers -m shell -a "pm2 stop all" -b -u mpi

# 5. Perform maintenance tasks
# - System updates
# - Configuration changes
# - Hardware maintenance

# 6. Start applications
ansible web_servers -m shell -a "pm2 start all" -b -u mpi

# 7. Start load balancer
ansible pi-lb -m systemd -a "name=nginx state=started" -b

# 8. Verify services
ansible-playbook playbooks/validate-cluster.yml

echo "=== Maintenance window complete ==="
```

This operations runbook provides comprehensive procedures for managing your Pi cluster in production environments.
