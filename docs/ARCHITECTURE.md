# Pi Cluster Architecture Documentation

## System Overview

The Pi Cluster is a distributed system built on Raspberry Pi hardware, implementing a modern web application stack with high availability, load balancing, and automated deployment.

## Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │   Web Server 1  │    │   Web Server 2  │    │   Database      │
│     (pi-lb)     │    │    (pi-web1)    │    │    (pi-web2)    │    │     (pi-db)     │
│                 │    │                 │    │                 │    │                 │
│  nginx + Angular│◄──►│  Node.js + PM2  │    │  Node.js + PM2  │    │    MariaDB      │
│  192.168.254.121│    │ 192.168.254.122 │    │ 192.168.254.123 │    │ 192.168.254.124 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │                       │
         └───────────────────────┼───────────────────────┼───────────────────────┘
                                 │                       │
                                 └───────────────────────┘
                                    Database Connections
```

## Component Architecture

### Load Balancer (pi-lb)

**Role**: Entry point and traffic distribution
**IP**: 192.168.254.121

**Components**:
- **nginx**: Reverse proxy and load balancer
- **Angular Dashboard**: Real-time monitoring interface
- **Static File Serving**: Frontend assets

**Configuration**:
```nginx
upstream backend {
    server 192.168.254.122:3000;
    server 192.168.254.123:3000;
}

server {
    listen 80;
    location /api/ {
        proxy_pass http://backend/;
    }
    location / {
        root /var/www/html;
        try_files $uri $uri/ /index.html;
    }
}
```

### Web Servers (pi-web1, pi-web2)

**Role**: Application processing and API endpoints
**IPs**: 192.168.254.122, 192.168.254.123

**Components**:
- **Node.js**: Runtime environment
- **Express.js**: Web framework
- **PM2**: Process manager
- **nginx**: Local reverse proxy (optional)

**Application Stack**:
```javascript
Express App → Database Connection Pool → MariaDB
     ↑
   PM2 Process Manager
     ↑
  System Service
```

### Database Server (pi-db)

**Role**: Data persistence and management
**IP**: 192.168.254.124

**Components**:
- **MariaDB**: Primary database
- **Optimized Configuration**: SSD-specific tuning
- **Backup System**: Automated backups

**Database Schema**:
```sql
-- Application database
CREATE DATABASE webapp_db;
CREATE USER 'webapp_user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON webapp_db.* TO 'webapp_user'@'%';
```

## Network Architecture

### Network Topology
```
Internet
    │
    ▼
┌─────────────┐
│   Router    │
│ 192.168.254.1│
└─────────────┘
    │
    ▼
┌─────────────┐
│   Switch    │
│  (Gigabit)  │
└─────────────┘
    │
    ├── pi-lb    (192.168.254.121)
    ├── pi-web1  (192.168.254.122)
    ├── pi-web2  (192.168.254.123)
    └── pi-db    (192.168.254.124)
```

### Port Configuration
| Service | Port | Access |
|---------|------|--------|
| HTTP | 80 | Public |
| HTTPS | 443 | Public |
| SSH | 22 | Internal |
| Node.js | 3000 | Internal |
| MariaDB | 3306 | Internal |

### Security Groups
```
Load Balancer:
- Inbound: 80, 443, 22
- Outbound: 3000 (to web servers)

Web Servers:
- Inbound: 3000 (from LB), 22
- Outbound: 3306 (to database)

Database:
- Inbound: 3306 (from web servers), 22
- Outbound: None
```

## Data Flow

### Request Processing
```
1. Client Request → Load Balancer (nginx)
2. Load Balancer → Web Server (round-robin)
3. Web Server → Database (connection pool)
4. Database → Web Server (query results)
5. Web Server → Load Balancer (JSON response)
6. Load Balancer → Client (HTTP response)
```

### Load Balancing Algorithm
- **Method**: Round-robin
- **Health Checks**: Passive (nginx)
- **Failover**: Automatic removal of failed backends
- **Session Persistence**: None (stateless)

## Service Architecture

### Process Management

**PM2 Configuration**:
```javascript
module.exports = {
  apps: [{
    name: 'pi-cluster-app',
    script: 'app.js',
    instances: 1,
    autorestart: true,
    max_memory_restart: '400M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};
```

**Service Dependencies**:
```
nginx.service
├── Requires: network.target
└── After: network.target

mariadb.service
├── Requires: network.target
└── After: network.target

pm2-mpi.service
├── Requires: network.target mariadb.service
└── After: network.target mariadb.service
```

### Health Monitoring

**Health Check Endpoints**:
- `/health` - Application health
- `/api/` - Full system status
- nginx status page (internal)

**Monitoring Flow**:
```
Angular Dashboard → API Endpoints → Database Status
       ↓
   Real-time Updates (10s interval)
       ↓
   Visual Status Display
```

## Deployment Architecture

### Ansible Structure
```
pi-cluster-ansible/
├── inventories/
│   └── production/
│       └── hosts
├── group_vars/
│   └── all.yml
├── roles/
│   ├── common/
│   ├── database/
│   ├── nodejs/
│   ├── webapp/
│   ├── nginx/
│   └── angular/
└── playbooks/
    └── site.yml
```

### Role Dependencies
```
common (base system)
├── database (MariaDB setup)
├── nodejs (Node.js runtime)
│   └── webapp (application deployment)
├── nginx (load balancer)
└── angular (frontend dashboard)
```

## Scalability Architecture

### Horizontal Scaling

**Web Tier Scaling**:
```bash
# Add new web server
pi-web3 (192.168.254.125)
pi-web4 (192.168.254.126)
...
```

**Database Scaling**:
```bash
# Read replicas
pi-db-read1 (192.168.254.127)
pi-db-read2 (192.168.254.128)
```

### Vertical Scaling
- Raspberry Pi 4 8GB models
- USB 3.0 SSD storage
- Faster network infrastructure

## Security Architecture

### Network Security
```
Firewall Rules:
├── Drop all by default
├── Allow SSH (22) from management network
├── Allow HTTP/HTTPS (80/443) from internet
└── Allow internal communication (3000, 3306)
```

### Application Security
- Input validation
- SQL injection prevention
- XSS protection headers
- CORS configuration
- Rate limiting (planned)

### Data Security
- Database user isolation
- Encrypted connections (planned)
- Regular security updates
- Backup encryption (planned)

## Performance Architecture

### Caching Strategy
```
Browser Cache → nginx Static Files → Application Cache → Database
     (1d)           (1y)                (memory)        (disk)
```

### Connection Pooling
```javascript
Database Pool:
├── Max Connections: 10
├── Acquire Timeout: 60s
├── Idle Timeout: 300s
└── Retry Logic: 3 attempts
```

### Resource Allocation
| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Load Balancer | 1 core | 1GB | 16GB |
| Web Server | 2 cores | 2GB | 16GB |
| Database | 2 cores | 2GB | 32GB |

## Disaster Recovery Architecture

### Backup Strategy
```
Database Backups:
├── Full backup (daily)
├── Incremental backup (hourly)
├── Transaction log backup (15min)
└── Retention: 30 days
```

### Recovery Procedures
1. **Service Recovery**: Restart failed services
2. **Node Recovery**: Redeploy to replacement hardware
3. **Data Recovery**: Restore from backups
4. **Full Recovery**: Complete cluster rebuild

### High Availability
- **RTO**: 5 minutes (service restart)
- **RPO**: 15 minutes (transaction logs)
- **Availability**: 99.9% target

## Monitoring Architecture

### Metrics Collection
```
System Metrics → Application Metrics → Business Metrics
     (htop)           (PM2)              (API calls)
       ↓                ↓                    ↓
   Log Files    →   Dashboard    →    Alerting
```

### Observability Stack (Future)
- **Metrics**: Prometheus + Grafana
- **Logs**: ELK Stack or Loki
- **Tracing**: Jaeger (for microservices)
- **Alerting**: AlertManager

This architecture provides a solid foundation for a production-ready Pi cluster with room for growth and enhancement.
