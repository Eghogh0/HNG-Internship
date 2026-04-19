const fs = require("fs");
const path = require("path");

// Absolute path: project_root/data.json
const filePath = path.join(process.cwd(), "data.json");

function readData() {
  try {
    if (!fs.existsSync(filePath)) {
      return [];
    }
    const data = fs.readFileSync(filePath, "utf-8");
    return JSON.parse(data || "[]");
  } catch (err) {
    console.error("❌ Error reading data.json:", err);
    return [];
  }
}

function writeData(data) {
  try {
    // Ensure the directory exists (process.cwd() always exists, but safe)
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
    console.log(`✅ Data written to ${filePath}`);
  } catch (err) {
    console.error("❌ Error writing data.json:", err);
  }
}

module.exports = { readData, writeData };