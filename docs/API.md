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
Returns comprehensive server information.

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
- `server` - Hostname of responding server
- `uptime` - Process uptime in seconds
- `database` - Database connection status
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

### Metrics Endpoints
```bash
# Process metrics
GET /metrics

# Database metrics  
GET /db/metrics

# System metrics
GET /system/metrics
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
done
```

## Database Schema

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
- Response time: < 50ms average
- Throughput: 1000+ requests/second
- Memory usage: ~60MB per process
- CPU usage: < 5% under normal load

### Optimization
```javascript
// PM2 cluster mode
module.exports = {
  apps: [{
    name: 'pi-cluster-app',
    script: 'app.js',
    instances: 'max',
    exec_mode: 'cluster'
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
    name: 'pi-cluster-app',
    script: 'app.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '400M',
    env: {
      NODE_ENV: 'production'
    }
  }]
};
```

## Changelog

### v1.0.0 (Current)
- Basic health check endpoint
- Server status endpoint
- Database connectivity testing
- Load balancing support
- Error handling

### Planned Features
- Authentication system
- Metrics collection
- Real-time WebSocket updates
- Cluster management endpoints
- Performance monitoring
