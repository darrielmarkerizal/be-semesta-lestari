require('dotenv').config();

const express = require('express');

const app = express();

console.log('ENV TEST');
console.log(process.env);
console.log('PORT:', process.env.PORT);

const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send({
    message: 'Hello World',
    port: process.env.PORT,
    env: process.env.NODE_ENV
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
