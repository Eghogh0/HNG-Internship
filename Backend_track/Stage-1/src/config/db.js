const initSqlJs = require("sql.js");
const fs = require("fs");
const path = require("path");

const DB_PATH = path.join(__dirname, "../../database.sqlite");

let db = null;

async function initializeDatabase() {
  const SQL = await initSqlJs();
  
  let fileBuffer = null;
  if (fs.existsSync(DB_PATH)) {
    fileBuffer = fs.readFileSync(DB_PATH);
  }
  
  db = new SQL.Database(fileBuffer);
  
  // Create table if not exists
  db.run(`
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
  
  // Save to disk after each write operation
  const originalRun = db.run.bind(db);
  db.run = function(sql, params) {
    const result = originalRun(sql, params);
    const data = db.export();
    fs.writeFileSync(DB_PATH, Buffer.from(data));
    return result;
  };
  
  return db;
}

function getDb() {
  if (!db) throw new Error("Database not initialized. Call initializeDatabase() first.");
  return db;
}

module.exports = { initializeDatabase, getDb };