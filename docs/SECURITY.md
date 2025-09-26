# Security Implementation

## Overview
The Pi Cluster implements multiple layers of security including JWT authentication, API keys, and rate limiting. All security features are deployed and operational.

## Authentication Methods

### 1. API Keys
- **Purpose**: Protect API endpoints from unauthorized access
- **Usage**: Include `X-API-Key` header in requests
- **Configuration**: Set in vault_api_keys variable
- **Status**: ✅ Deployed and working

### 2. JWT Tokens
- **Purpose**: Admin authentication with time-based expiration
- **Expiration**: 1 hour
- **Usage**: Bearer token in Authorization header
- **Status**: ✅ Deployed and working

### 3. Rate Limiting
- **General API**: 100 requests per 15 minutes per IP
- **Authentication**: 5 attempts per 15 minutes per IP
- **Protection**: Prevents brute force and DoS attacks
- **Status**: ✅ Deployed and active

## Security Headers
- **Helmet.js**: Implements security headers
- **CORS**: Cross-origin resource sharing protection
- **Status**: ✅ Deployed and active

## Deployment Configuration
```bash
# Vault password file configured
vault_password_file = .vault_pass

# Automated deployment
make deploy
```

## Testing Security Features
```bash
# Test health endpoint (public)
curl http://192.168.254.122:3000/health

# Test API key protection
curl -H "X-API-Key: api-key-dashboard-2024" \
  http://192.168.254.122:3000/api/status

# Test JWT authentication
curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"SecureAdminPass123!"}' \
  http://192.168.254.122:3000/api/auth/login
```

## Vault Configuration
Security secrets are stored in encrypted vault files:
- `group_vars/all/vault.yml` - All encrypted secrets
- `.vault_pass` - Vault password file (not in git)

## Best Practices
1. ✅ Strong, unique API keys implemented
2. ✅ JWT secrets properly encrypted
3. ✅ Rate limiting active and tested
4. ✅ Vault password file secured
5. ✅ All endpoints tested and working
