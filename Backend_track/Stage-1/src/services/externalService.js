const axios = require("axios");

async function fetchExternalData(name) {
  const endpoints = [
    { name: "Genderize", url: `https://api.genderize.io?name=${name}` },
    { name: "Agify",     url: `https://api.agify.io?name=${name}` },
    { name: "Nationalize", url: `https://api.nationalize.io?name=${name}` }
  ];

  // Request all three APIs in parallel with a 10s timeout
  const promises = endpoints.map(async (ep) => {
    try {
      const res = await axios.get(ep.url, { timeout: 10000 });
      return { type: ep.name, data: res.data, ok: true };
    } catch (err) {
      return { type: ep.name, ok: false, error: err };
    }
  });

  const results = await Promise.all(promises);

  // Log any failed requests (visible in Railway logs)
  for (const res of results) {
    if (!res.ok) {
      console.error(`❌ ${res.type} API failed:`, res.error.message);
    }
  }

  // Extract successful responses
  const genderRes = results.find(r => r.type === "Genderize" && r.ok);
  const ageRes    = results.find(r => r.type === "Agify" && r.ok);
  const nationRes = results.find(r => r.type === "Nationalize" && r.ok);

  // Validate Genderize
  if (!genderRes || !genderRes.data.gender || genderRes.data.count === 0) {
    throw { type: "Genderize" };
  }

  // Validate Agify (age can be null – treat as failure)
  if (!ageRes || ageRes.data.age === undefined || ageRes.data.age === null) {
    throw { type: "Agify" };
  }

  // Validate Nationalize
  if (!nationRes || !Array.isArray(nationRes.data.country) || nationRes.data.country.length === 0) {
    throw { type: "Nationalize" };
  }

  // Get country with highest probability
  const topCountry = nationRes.data.country.reduce((best, curr) =>
    curr.probability > best.probability ? curr : best
  );

  return {
    gender: genderRes.data.gender,
    gender_probability: genderRes.data.probability || 0,
    sample_size: genderRes.data.count,
    age: ageRes.data.age,
    country_id: topCountry.country_id,
    country_probability: topCountry.probability || 0
  };
}

module.exports = fetchExternalData;