# Security Implementation

## Overview
The Pi Cluster implements multiple layers of security including JWT authentication, API keys, and rate limiting.

## Authentication Methods

### 1. API Keys
- **Purpose**: Protect API endpoints from unauthorized access
- **Usage**: Include `X-API-Key` header in requests
- **Configuration**: Set in `vault_api_keys` variable

### 2. JWT Tokens
- **Purpose**: Admin authentication with time-based expiration
- **Expiration**: 1 hour
- **Usage**: Bearer token in Authorization header

### 3. Rate Limiting
- **General API**: 100 requests per 15 minutes per IP
- **Authentication**: 5 attempts per 15 minutes per IP
- **Protection**: Prevents brute force and DoS attacks

## Security Headers
- **Helmet.js**: Implements security headers
- **CORS**: Cross-origin resource sharing protection

## Environment Variables
```bash
JWT_SECRET=your-secret-key
API_KEYS=key1,key2,key3
ADMIN_PASSWORD=secure-password
```

## Best Practices
1. Use strong, unique API keys
2. Rotate JWT secrets regularly
3. Monitor rate limit violations
4. Use HTTPS in production
5. Implement proper logging

## Vault Configuration
Security secrets are stored in encrypted vault files:
- `group_vars/all/vault.yml` - Database passwords
- `group_vars/all/vault_security.yml` - JWT secrets and API keys
