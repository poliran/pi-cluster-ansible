const express = require('express');
const os = require('os');
const mysql = require('mysql2/promise');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: { error: 'Too many requests, please try again later' }
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5, // limit auth attempts
  message: { error: 'Too many authentication attempts' }
});

app.use('/api/', limiter);
app.use('/api/auth/', authLimiter);

// Database connection
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'webapp_user',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'webapp_db'
};

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const API_KEYS = (process.env.API_KEYS || 'default-api-key').split(',');

// Middleware: API Key validation
const validateApiKey = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (!apiKey || !API_KEYS.includes(apiKey)) {
    return res.status(401).json({ error: 'Invalid API key' });
  }
  next();
};

// Middleware: JWT validation
const validateJWT = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// Public endpoints
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', server: os.hostname() });
});

// Authentication endpoint
app.post('/api/auth/login', async (req, res) => {
  const { username, password } = req.body;
  
  // Simple auth (in production, use proper user management)
  if (username === 'admin' && password === process.env.ADMIN_PASSWORD) {
    const token = jwt.sign(
      { username, role: 'admin' },
      JWT_SECRET,
      { expiresIn: '1h' }
    );
    res.json({ token, expiresIn: 3600 });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// Protected endpoints (require API key)
app.get('/api/status', validateApiKey, async (req, res) => {
  const hostname = os.hostname();
  const uptime = process.uptime();
  
  try {
    const connection = await mysql.createConnection(dbConfig);
    await connection.execute('SELECT 1');
    await connection.end();
    
    res.json({
      message: 'Pi Cluster Web App',
      server: hostname,
      uptime: `${Math.floor(uptime)}s`,
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.json({
      message: 'Pi Cluster Web App',
      server: hostname,
      uptime: `${Math.floor(uptime)}s`,
      database: 'disconnected',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Admin endpoints (require JWT)
app.get('/api/admin/metrics', validateJWT, (req, res) => {
  res.json({
    server: os.hostname(),
    memory: process.memoryUsage(),
    uptime: process.uptime(),
    loadavg: os.loadavg(),
    user: req.user
  });
});

// Legacy endpoint for backward compatibility
app.get('/', validateApiKey, async (req, res) => {
  const hostname = os.hostname();
  const uptime = process.uptime();
  
  try {
    const connection = await mysql.createConnection(dbConfig);
    await connection.execute('SELECT 1');
    await connection.end();
    
    res.json({
      message: 'Pi Cluster Web App',
      server: hostname,
      uptime: `${Math.floor(uptime)}s`,
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.json({
      message: 'Pi Cluster Web App',
      server: hostname,
      uptime: `${Math.floor(uptime)}s`,
      database: 'disconnected',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

app.listen(port, () => {
  console.log(`Secure server running on port ${port}`);
});
