require('dotenv').config();

console.log('STEP 1');

const express = require('express');
const mysql = require('mysql2/promise');

const app = express();

const PORT = 3000;

app.get('/', (req, res) => {
  res.send('Hello World');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);

  connectDB();
});

async function connectDB() {
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
}
