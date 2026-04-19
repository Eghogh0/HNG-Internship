const axios = require("axios");

async function fetchExternalData(name) {
  try {
    const [genderRes, ageRes, natRes] = await Promise.all([
      axios.get(`https://api.genderize.io?name=${name}`).catch(() => null),
      axios.get(`https://api.agify.io?name=${name}`).catch(() => null),
      axios.get(`https://api.nationalize.io?name=${name}`).catch(() => null)
    ]);

    const g = genderRes?.data;
    const a = ageRes?.data;
    const n = natRes?.data;

    // SAFER VALIDATION (THIS IS KEY FIX)
    if (!g || !g.gender) {
      throw { type: "Genderize" };
    }

    if (typeof a?.age !== "number") {
      throw { type: "Agify" };
    }

    if (!n?.country || n.country.length === 0) {
      throw { type: "Nationalize" };
    }

    const topCountry = n.country.reduce((max, curr) =>
      curr.probability > max.probability ? curr : max
    );

    return {
      gender: g.gender,
      gender_probability: g.probability || 0,
      sample_size: g.count || 0,
      age: a.age,
      country_id: topCountry.country_id,
      country_probability: topCountry.probability
    };

  } catch (err) {
    throw err;
  }
}

module.exports = fetchExternalData;