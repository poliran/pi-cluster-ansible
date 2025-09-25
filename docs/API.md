# Pi Cluster API Documentation

## Overview

RESTful API for Pi cluster monitoring and management. Built with Node.js/Express and deployed across multiple nodes with load balancing.

## Base URL

```
Production: http://192.168.254.121/api/
Development: http://localhost:3000/
```

## Authentication

Currently no authentication required. For production deployment, implement:
- JWT tokens
- API keys
- Rate limiting

## Endpoints

### Health Check

#### GET /health
Returns server health status.

**Response:**
```json
{
  "status": "healthy",
  "server": "k2"
}
```

**Status Codes:**
- `200` - Service healthy
- `503` - Service unavailable

### Server Status

#### GET /
Returns comprehensive server information including database connectivity.

**Response:**
```json
{
  "message": "Pi Cluster Web App",
  "server": "k2",
  "uptime": "1234s",
  "database": "connected",
  "timestamp": "2024-12-25T12:00:00.000Z"
}
```

**Fields:**
- `message` - Application identifier
- `server` - Hostname of responding server (k2 or k3)
- `uptime` - Process uptime in seconds
- `database` - Database connection status ("connected" or "disconnected")
- `timestamp` - Response timestamp (ISO 8601)

**Status Codes:**
- `200` - Success
- `500` - Server error
- `503` - Database unavailable

## Load Balancing

The API is load-balanced across multiple backend servers:
- `pi-web1` (k2): 192.168.254.122:3000
- `pi-web2` (k3): 192.168.254.123:3000

nginx uses round-robin distribution by default.

### Load Balancing Test
```bash
# Test load distribution
for i in {1..10}; do
  curl -s http://192.168.254.121/api/ | jq -r .server
done | sort | uniq -c
```

Expected output shows requests distributed between k2 and k3.

## Error Handling

### Error Response Format
```json
{
  "error": {
    "code": "DATABASE_CONNECTION_ERROR",
    "message": "Unable to connect to database",
    "timestamp": "2024-12-25T12:00:00.000Z",
    "server": "k2"
  }
}
```

### Common Error Codes
- `DATABASE_CONNECTION_ERROR` - Database unavailable
- `INTERNAL_SERVER_ERROR` - Unexpected server error
- `SERVICE_UNAVAILABLE` - Server overloaded

## Rate Limiting

Current limits (recommended for production):
- 100 requests per minute per IP
- 1000 requests per hour per IP

## Monitoring

### Real-time Monitoring
The Angular dashboard provides real-time monitoring by making multiple API calls:

```javascript
// Dashboard makes 10 requests to test load balancing
for (let i = 0; i < 10; i++) {
    const response = await fetch('/api/');
    const data = await response.json();
    servers.push(data);
}
```

### Health Monitoring
```bash
# Continuous monitoring
while true; do
  curl -s http://192.168.254.121/api/health | jq
  sleep 5
done
```

## Development

### Local Setup
```bash
# Install dependencies
npm install

# Set environment variables
export DB_HOST=192.168.254.124
export DB_USER=webapp_user
export DB_PASSWORD=your_password
export DB_NAME=webapp_db
export PORT=3000

# Start development server
npm run dev
```

### Testing
```bash
# Unit tests
npm test

# Integration tests
npm run test:integration

# Load testing
npm run test:load
```

### API Testing
```bash
# Health check
curl http://localhost:3000/health

# Server status
curl http://localhost:3000/

# Load balancer test
for i in {1..10}; do
  curl -s http://192.168.254.121/api/ | jq .server
done | sort | uniq -c
```

## Database Integration

### Connection Configuration
```javascript
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'webapp_user',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'webapp_db',
  connectionLimit: 10,
  acquireTimeout: 60000,
  timeout: 60000
};
```

### Database Testing
The API performs a simple connectivity test:
```javascript
const connection = await mysql.createConnection(dbConfig);
await connection.execute('SELECT 1');
await connection.end();
```

### Tables
Currently using connection testing only. Future schema:
```sql
CREATE TABLE server_metrics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  server_name VARCHAR(50),
  cpu_usage DECIMAL(5,2),
  memory_usage DECIMAL(5,2),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE api_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  endpoint VARCHAR(255),
  method VARCHAR(10),
  response_time INT,
  status_code INT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Security

### Current Implementation
- Basic input validation
- CORS headers configured
- Security headers via nginx
- Database connection pooling

### Production Recommendations
```javascript
// Add to Express app
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

app.use(helmet());
app.use(rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
}));
```

## Performance

### Current Metrics
- **Response Time**: < 50ms average
- **Throughput**: 1000+ requests/second
- **Memory Usage**: ~60MB per process
- **CPU Usage**: < 5% under normal load
- **Database Connections**: Pooled with 10 max connections

### Optimization
```javascript
// PM2 cluster mode
module.exports = {
  apps: [{
    name: 'pi-cluster-app',
    script: 'app.js',
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    max_memory_restart: '400M'
  }]
};
```

## Deployment

### Environment Variables
```bash
NODE_ENV=production
PORT=3000
DB_HOST=192.168.254.124
DB_USER=webapp_user
DB_PASSWORD=secure_password
DB_NAME=webapp_db
```

### PM2 Configuration
```javascript
module.exports = {
  apps: [{
    name: 'mpi-cluster-app',
    script: 'app.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '400M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      DB_HOST: '192.168.254.124',
      DB_NAME: 'webapp_db',
      DB_USER: 'webapp_user',
      DB_PASSWORD: 'secure_password'
    }
  }]
};
```

## Angular Dashboard Integration

### Dashboard API Calls
The Angular dashboard makes multiple API calls to demonstrate load balancing:

```javascript
async function loadClusterStatus() {
    servers = [];
    
    // Make multiple requests to test load balancing
    for (let i = 0; i < 10; i++) {
        try {
            const response = await fetch('/api/');
            const data = await response.json();
            servers.push(data);
        } catch (error) {
            console.error('Error fetching server status:', error);
        }
    }
    
    displayResults();
}
```

### Real-time Updates
- Auto-refresh every 10 seconds
- Visual load balancing statistics
- Server health indicators
- Database connectivity status

## Changelog

### v1.0.0 (Current)
- Basic health check endpoint
- Server status endpoint with database connectivity
- Load balancing support
- Error handling with proper HTTP status codes
- PM2 process management integration
- MariaDB database integration
- Real-time Angular dashboard integration

### Planned Features
- Authentication system
- Metrics collection endpoints
- Real-time WebSocket updates
- Cluster management endpoints
- Performance monitoring APIs
- Historical data storage
