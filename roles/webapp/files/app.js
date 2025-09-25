const express = require('express');
const os = require('os');
const mysql = require('mysql2/promise');

const app = express();
const port = process.env.PORT || 3000;

// Database connection
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'webapp_user',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'webapp_db'
};

app.get('/', async (req, res) => {
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

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', server: os.hostname() });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
