const axios = require("axios");

async function fetchExternalData(name) {
  const genderRes = await axios.get(`https://api.genderize.io?name=${name}`);
  const ageRes = await axios.get(`https://api.agify.io?name=${name}`);
  const natRes = await axios.get(`https://api.nationalize.io?name=${name}`);

  const g = genderRes.data;
  const a = ageRes.data;
  const n = natRes.data;

  // SAFE VALIDATION (IMPORTANT FIX)
  if (!g || !g.gender || g.probability === undefined) {
    throw { type: "Genderize" };
  }

  if (!a || typeof a.age !== "number") {
    throw { type: "Agify" };
  }

  if (!n || !n.country || n.country.length === 0) {
    throw { type: "Nationalize" };
  }

  const topCountry = n.country.sort((a, b) => b.probability - a.probability)[0];

  return {
    gender: g.gender,
    gender_probability: g.probability,
    sample_size: g.count || 0,
    age: a.age,
    country_id: topCountry.country_id,
    country_probability: topCountry.probability
  };
}

module.exports = fetchExternalData;