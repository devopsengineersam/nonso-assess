const express = require('express');
const app = express();
const axios = require('axios');

app.use(express.static('public'));
app.use(express.json());

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/public/index.html');
});

app.post('/add-item', async (req, res) => {
  try {
    const response = await axios.post('http://api:4000/items', req.body);
    res.status(200).send(response.data);
  } catch (error) {
    res.status(500).send('Error adding item');
  }
});

app.get('/items', async (req, res) => {
  try {
    const response = await axios.get('http://api:4000/items');
    res.status(200).send(response.data);
  } catch (error) {
    res.status(500).send('Error fetching items');
  }
});

app.listen(3000, () => {
  console.log('Web app running on http://localhost:3000');
});