const db = require("../config/db");
const { v7: uuidv7 } = require("uuid");
const fetchExternalData = require("../services/externalService");
const getAgeGroup = require("../utils/ageGroup");
const errorResponse = require("../utils/errors");

// CREATE PROFILE
exports.createProfile = (req, res) => {
  const { name } = req.body;

  if (!name) return errorResponse(res, 400, "Missing or empty name");
  if (typeof name !== "string") return errorResponse(res, 422, "Invalid type");

  const lowerName = name.toLowerCase();

  // Check duplicate
  db.get("SELECT * FROM profiles WHERE name = ?", [lowerName], async (err, row) => {
    if (row) {
      return res.status(200).json({
        status: "success",
        message: "Profile already exists",
        data: row
      });
    }

    try {
      const data = await fetchExternalData(lowerName);

      const age_group = getAgeGroup(data.age);
      const id = uuidv7();
      const created_at = new Date().toISOString();

      const profile = {
        id,
        name: lowerName,
        ...data,
        age_group,
        created_at
      };

      db.run(
        `INSERT INTO profiles VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
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
        ]
      );

      return res.status(201).json({
        status: "success",
        data: profile
      });

    } catch (err) {
      return errorResponse(
        res,
        502,
        `${err.type} returned an invalid response`
      );
    }
  });
};

// GET SINGLE
exports.getProfile = (req, res) => {
  const { id } = req.params;

  db.get("SELECT * FROM profiles WHERE id = ?", [id], (err, row) => {
    if (!row) return errorResponse(res, 404, "Profile not found");

    res.json({
      status: "success",
      data: row
    });
  });
};

// GET ALL WITH FILTER
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

  db.all(query, params, (err, rows) => {
    res.json({
      status: "success",
      count: rows.length,
      data: rows
    });
  });
};

// DELETE
exports.deleteProfile = (req, res) => {
  const { id } = req.params;

  db.run("DELETE FROM profiles WHERE id = ?", [id], function (err) {
    if (this.changes === 0) {
      return errorResponse(res, 404, "Profile not found");
    }

    res.status(204).send();
  });
};