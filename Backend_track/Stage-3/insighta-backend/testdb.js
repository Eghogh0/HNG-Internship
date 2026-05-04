const { Client } = require('pg');
require('dotenv').config();

const url = process.env.DATABASE_URL;
console.log('URL length:', url.length);
console.log('URL JSON:', JSON.stringify(url));
// Also try explicit params
const client = new Client({
  host: '127.0.0.1',  // try 127.0.0.1
  port: 5432,
  user: 'postgres',
  password: 'Ibilolia2005',
  database: 'insighta',
});
client.connect().then(() => {
  console.log('Connection with explicit params successful!');
  client.end();
}).catch(err => console.error('Explicit params failed:', err.message));