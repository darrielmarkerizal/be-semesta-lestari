console.log('STEP 1');

require('dotenv').config();

console.log('STEP 2');

const express = require('express');

console.log('STEP 3');

const mysql = require('mysql2/promise');

console.log('STEP 4');

const app = express();

console.log('STEP 5');

console.log({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT
});

const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello World');
});

app.listen(PORT, async () => {
  console.log(`Server running on port ${PORT}`);

  try {
    console.log('Connecting to database...');

    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT || 3306,
      connectTimeout: 5000
    });

    console.log('✅ DATABASE CONNECTED');

    await connection.end();
  } catch (error) {
    console.error('❌ DATABASE ERROR');
    console.error(error);
  }
});
