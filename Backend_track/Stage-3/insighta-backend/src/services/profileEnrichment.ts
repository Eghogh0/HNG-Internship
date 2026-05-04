import axios from 'axios';

export async function enrichProfile(name: string) {
  const [genderRes, ageRes, nationRes] = await Promise.all([
    axios.get(`https://api.genderize.io?name=${encodeURIComponent(name.split(' ')[0])}`),
    axios.get(`https://api.agify.io?name=${encodeURIComponent(name.split(' ')[0])}`),
    axios.get(`https://api.nationalize.io?name=${encodeURIComponent(name.split(' ')[0])}`),
  ]);
  const genderData = genderRes.data;
  const ageData = ageRes.data;
  const countryData = nationRes.data;
  const country = countryData.country?.length ? countryData.country[0] : { country_id: 'US', probability: 0 };
  
  return {
    gender: genderData.gender || 'unknown',
    gender_probability: genderData.probability || 0,
    age: ageData.age || 0,
    country_id: country.country_id,
    country_name: getCountryName(country.country_id), // simple mapping
    country_probability: country.probability || 0,
    age_group: getAgeGroup(ageData.age),
  };
}

function getAgeGroup(age: number): string {
  if (age < 13) return 'child';
  if (age < 20) return 'teenager';
  if (age < 65) return 'adult';
  return 'senior';
}

function getCountryName(code: string): string {
  const mapping: Record<string, string> = {
    US: 'United States',
    NG: 'Nigeria',
    KE: 'Kenya',
    // add more
  };
  return mapping[code] || code;
}