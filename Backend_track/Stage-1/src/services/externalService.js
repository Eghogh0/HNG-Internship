const axios = require("axios");

async function safeGet(url, apiName) {
  try {
    const res = await axios.get(url, { timeout: 10000 });
    // If the response is empty or malformed, treat as failure
    if (!res || !res.data) {
      throw new Error(`No data from ${apiName}`);
    }
    return res.data;
  } catch (err) {
    // Wrap any error (network, timeout, etc.) with the API name
    throw { type: apiName, originalError: err };
  }
}

function getTopCountry(countryData) {
  // Defensive: ensure countryData is a non‑empty array
  if (!Array.isArray(countryData) || countryData.length === 0) {
    throw { type: "Nationalize" };
  }
  return countryData.reduce((best, curr) =>
    curr.probability > best.probability ? curr : best
  );
}

async function fetchExternalData(name) {
  // Fetch all three APIs (could be parallel, but sequential is fine)
  const genderData = await safeGet(`https://api.genderize.io?name=${name}`, "Genderize");
  const ageData = await safeGet(`https://api.agify.io?name=${name}`, "Agify");
  const nationData = await safeGet(`https://api.nationalize.io?name=${name}`, "Nationalize");

  // ----- Validate Genderize response -----
  if (!genderData.gender || genderData.count === 0) {
    throw { type: "Genderize" };
  }

  // ----- Validate Agify response -----
  // ageData.age can be null; treat null as invalid
  if (ageData.age === undefined || ageData.age === null) {
    throw { type: "Agify" };
  }

  // ----- Validate Nationalize response -----
  // Ensure nationData.country exists and is an array
  if (!nationData.country || !Array.isArray(nationData.country) || nationData.country.length === 0) {
    throw { type: "Nationalize" };
  }

  const topCountry = getTopCountry(nationData.country);

  return {
    gender: genderData.gender,
    gender_probability: genderData.probability || 0,
    sample_size: genderData.count,
    age: ageData.age,
    country_id: topCountry.country_id,
    country_probability: topCountry.probability || 0
  };
}

module.exports = fetchExternalData;