const { v7: uuidv7 } = require("uuid");
const fetchExternalData = require("../services/externalService");
const getAgeGroup = require("../utils/ageGroup");
const errorResponse = require("../utils/errors");
const { readData, writeData } = require("../config/db");

// CREATE PROFILE
exports.createProfile = async (req, res) => {
  const { name } = req.body;

  if (!name) return errorResponse(res, 400, "Missing or empty name");
  if (typeof name !== "string") return errorResponse(res, 422, "Invalid type");

  const lowerName = name.toLowerCase();
  const data = readData();

  const existing = data.find(p => p.name === lowerName);
  if (existing) {
    return res.status(200).json({
      status: "success",
      message: "Profile already exists",
      data: existing
    });
  }

  try {
    const external = await fetchExternalData(lowerName);

    const profile = {
      id: uuidv7(),
      name: lowerName,
      ...external,
      age_group: getAgeGroup(external.age),
      created_at: new Date().toISOString()
    };

    data.push(profile);
    writeData(data);

    return res.status(201).json({
      status: "success",
      data: profile
    });

  } catch (err) 
  {
  return res.status(502).json
  ({
    status: "error",
    message: `${err.type} returned an invalid response`
  });
  }
};

// GET SINGLE PROFILE
exports.getProfile = (req, res) => {
  const { id } = req.params;
  const data = readData();

  const profile = data.find(p => p.id === id);
  if (!profile) return errorResponse(res, 404, "Profile not found");

  res.json({
    status: "success",
    data: profile
  });
};

// GET ALL PROFILES
exports.getAllProfiles = (req, res) => {
  const { gender, country_id, age_group } = req.query;
  let data = readData();

  if (gender) {
    data = data.filter(p => p.gender.toLowerCase() === gender.toLowerCase());
  }

  if (country_id) {
    data = data.filter(p => p.country_id.toLowerCase() === country_id.toLowerCase());
  }

  if (age_group) {
    data = data.filter(p => p.age_group.toLowerCase() === age_group.toLowerCase());
  }

  const result = data.map(p => ({
    id: p.id,
    name: p.name,
    gender: p.gender,
    age: p.age,
    age_group: p.age_group,
    country_id: p.country_id
  }));

  res.json({
    status: "success",
    count: result.length,
    data: result
  });
};

// DELETE PROFILE
exports.deleteProfile = (req, res) => {
  const { id } = req.params;
  let data = readData();

  const index = data.findIndex(p => p.id === id);
  if (index === -1) return errorResponse(res, 404, "Profile not found");

  data.splice(index, 1);
  writeData(data);

  res.status(204).send();
};