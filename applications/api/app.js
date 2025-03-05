const express = require('express');
const app = express();
const mysql = require('mysql2'); // Use mysql2 instead of pg

// Database configuration
const dbConfig = {
  host: process.env.DBHOST,
  user: process.env.DBUSER,
  password: process.env.DBPASS,
  database: process.env.DB,
  port: process.env.DBPORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

// Create a MySQL connection pool
const pool = mysql.createPool(dbConfig);

// Routes
app.get('/api/status', (req, res) => {
  pool.getConnection((err, connection) => {
    if (err) {
      console.error('Error acquiring connection:', err.stack);
      return res.status(500).send('Database connection error');
    }

    connection.query('SELECT NOW() AS time', (queryErr, results) => {
      connection.release(); // Always release the connection back to the pool

      if (queryErr) {
        console.error('Error executing query:', queryErr.stack);
        return res.status(500).send('Query execution error');
      }

      res.status(200).json(results[0]);
    });
  });
});

// Error handlers
app.use((req, res, next) => {
  res.status(404).json({ message: 'Not Found' });
});

app.use((err, req, res, next) => {
  res.status(err.status || 500).json({
    message: err.message,
    error: app.get('env') === 'development' ? err : {}
  });
});

const PORT = process.env.PORT || 4001;
app.listen(PORT, () => {
  console.log(`API running on port ${PORT}`);
});

module.exports = app;