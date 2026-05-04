// knexfile.js
require('dotenv').config();

console.log('DATABASE_URL:', process.env.DATABASE_URL);

module.exports = {
  development: {
    client: 'pg',
    connection: process.env.DATABASE_URL,
    migrations: {
      directory: './migrations',
    },
    seeds: {
      directory: './seeds',
    },
  },
};