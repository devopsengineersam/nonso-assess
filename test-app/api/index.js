const express = require('express');
const mysql = require('mysql2');
const app = express();

app.use(express.json());

const connection = mysql.createConnection({
  host: 'db',
  user: 'root',
  password: 'password',
  database: 'catalog',
});

connection.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL:', err.stack);
    return;
  }
  console.log('Connected to MySQL');
});

app.get('/items', (req, res) => {
  connection.query('SELECT * FROM items', (err, results) => {
    if (err) {
      res.status(500).send('Error fetching items');
    } else {
      res.status(200).json(results);
    }
  });
});

app.post('/items', (req, res) => {
  const { name, description } = req.body;
  connection.query(
    'INSERT INTO items (name, description) VALUES (?, ?)',
    [name, description],
    (err, results) => {
      if (err) {
        res.status(500).send('Error adding item');
      } else {
        res.status(200).send('Item added');
      }
    }
  );
});

app.get('/status', (req, res) => {
  res.status(200).send('API is running');
});

app.listen(4000, () => {
  console.log('API running on http://localhost:4000');
});