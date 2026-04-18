const db = require("../config/db");
const { v7: uuidv7 } = require("uuid");
const fetchExternalData = require("../services/externalService");
const getAgeGroup = require("../utils/ageGroup");
const errorResponse = require("../utils/errors");

// CREATE PROFILE
exports.createProfile = async (req, res) => {
  const { name } = req.body;

  if (!name) return errorResponse(res, 400, "Missing or empty name");
  if (typeof name !== "string") return errorResponse(res, 422, "Invalid type");

  const lowerName = name.toLowerCase();

  try {
    // Check duplicate (synchronous)
    const existing = db.prepare("SELECT * FROM profiles WHERE name = ?").get(lowerName);
    if (existing) {
      return res.status(200).json({
        status: "success",
        message: "Profile already exists",
        data: existing,
      });
    }

    const data = await fetchExternalData(lowerName);
    const age_group = getAgeGroup(data.age);
    const id = uuidv7();
    const created_at = new Date().toISOString();

    const profile = {
      id,
      name: lowerName,
      ...data,
      age_group,
      created_at,
    };

    const insert = db.prepare(`
      INSERT INTO profiles VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    insert.run(
      profile.id,
      profile.name,
      profile.gender,
      profile.gender_probability,
      profile.sample_size,
      profile.age,
      profile.age_group,
      profile.country_id,
      profile.country_probability,
      profile.created_at
    );

    return res.status(201).json({
      status: "success",
      data: profile,
    });
  } catch (err) {
    console.error(err);
    return errorResponse(
      res,
      502,
      err.type ? `${err.type} returned an invalid response` : err.message
    );
  }
};

// GET SINGLE PROFILE
exports.getProfile = (req, res) => {
  const { id } = req.params;

  try {
    const row = db.prepare("SELECT * FROM profiles WHERE id = ?").get(id);
    if (!row) return errorResponse(res, 404, "Profile not found");

    res.json({
      status: "success",
      data: row,
    });
  } catch (err) {
    return errorResponse(res, 500, err.message);
  }
};

// GET ALL PROFILES (with filters)
exports.getAllProfiles = (req, res) => {
  const { gender, country_id, age_group } = req.query;

  let query = "SELECT id, name, gender, age, age_group, country_id FROM profiles WHERE 1=1";
  const params = [];

  if (gender) {
    query += " AND LOWER(gender) = ?";
    params.push(gender.toLowerCase());
  }
  if (country_id) {
    query += " AND LOWER(country_id) = ?";
    params.push(country_id.toLowerCase());
  }
  if (age_group) {
    query += " AND LOWER(age_group) = ?";
    params.push(age_group.toLowerCase());
  }

  try {
    const stmt = db.prepare(query);
    const rows = stmt.all(...params);
    res.json({
      status: "success",
      count: rows.length,
      data: rows,
    });
  } catch (err) {
    return errorResponse(res, 500, err.message);
  }
};

// DELETE PROFILE
exports.deleteProfile = (req, res) => {
  const { id } = req.params;

  try {
    const result = db.prepare("DELETE FROM profiles WHERE id = ?").run(id);
    if (result.changes === 0) {
      return errorResponse(res, 404, "Profile not found");
    }
    res.status(204).send();
  } catch (err) {
    return errorResponse(res, 500, err.message);
  }
};