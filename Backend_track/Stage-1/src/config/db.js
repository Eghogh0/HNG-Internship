const Database = require("better-sqlite3");

// Open database file (creates if missing)
const db = new Database("./database.sqlite");

// Enable foreign keys (good practice)
db.pragma("foreign_keys = ON");

// Create the profiles table if it doesn't exist
const createTable = db.prepare(`
  CREATE TABLE IF NOT EXISTS profiles (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE,
    gender TEXT,
    gender_probability REAL,
    sample_size INTEGER,
    age INTEGER,
    age_group TEXT,
    country_id TEXT,
    country_probability REAL,
    created_at TEXT
  )
`);
createTable.run();

module.exports = db;