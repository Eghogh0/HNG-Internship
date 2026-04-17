const axios = require("axios");

async function fetchExternalData(name) {
  try {
    const [genderRes, ageRes, nationRes] = await Promise.all([
      axios.get(`https://api.genderize.io?name=${name}`),
      axios.get(`https://api.agify.io?name=${name}`),
      axios.get(`https://api.nationalize.io?name=${name}`)
    ]);

    const genderData = genderRes.data;
    const ageData = ageRes.data;
    const nationData = nationRes.data;

    // VALIDATION
    if (!genderData.gender || genderData.count === 0) {
      throw { type: "Genderize" };
    }

    if (ageData.age === null) {
      throw { type: "Agify" };
    }

    if (!nationData.country || nationData.country.length === 0) {
      throw { type: "Nationalize" };
    }

    // Get highest probability country
    const topCountry = nationData.country.reduce((max, curr) =>
      curr.probability > max.probability ? curr : max
    );

    return {
      gender: genderData.gender,
      gender_probability: genderData.probability,
      sample_size: genderData.count,
      age: ageData.age,
      country_id: topCountry.country_id,
      country_probability: topCountry.probability
    };

  } catch (err) {
    throw err;
  }
}

module.exports = fetchExternalData;