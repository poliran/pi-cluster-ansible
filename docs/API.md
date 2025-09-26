# API Documentation

## Authentication

### API Keys
Include API key in request headers:
```
X-API-Key: your-api-key
```

### JWT Tokens
1. Login to get token:
```bash
curl -X POST http://192.168.254.122:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your-password"}'
```

2. Use token in requests:
```
Authorization: Bearer your-jwt-token
```

## Rate Limiting
- General API: 100 requests per 15 minutes per IP
- Authentication: 5 requests per 15 minutes per IP

## Endpoints

### Public
- `GET /health` - Health check (no auth required)

### API Key Protected
- `GET /api/status` - Server status and security info

### JWT Protected (Admin)
- `POST /api/auth/login` - Authentication
- `GET /api/admin/metrics` - Detailed server metrics

## Examples

### Get Status
```bash
curl -H "X-API-Key: api-key-dashboard-2024" \
  http://192.168.254.122:3000/api/status
```

### Login
```bash
curl -X POST http://192.168.254.122:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"SecureAdminPass123!"}'
```

### Get Admin Metrics
```bash
curl -H "Authorization: Bearer your-jwt-token" \
  http://192.168.254.122:3000/api/admin/metrics
```

## Response Examples

### Health Check
```json
{"status":"healthy","server":"k2"}
```

### Status (with API key)
```json
{
  "message": "Pi Cluster Web App - Security Enabled",
  "server": "k2",
  "uptime": "17s",
  "security": "JWT + API Keys + Rate Limiting",
  "timestamp": "2025-09-26T03:45:37.056Z"
}
```

### Login Response
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600
}
```
