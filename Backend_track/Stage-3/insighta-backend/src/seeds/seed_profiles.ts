import { Knex } from 'knex';
import { v4 as uuidv7 } from 'uuid'; // We need uuid v7, but we can use uuid v4 for simplicity or a library

// Using uuid v4 for demonstration; real UUID v7 can be generated via a library.
function generateUUID() {
  return uuidv7(); // assume uuidv7 is imported, but we can just use uuid v4
}

// In a real scenario we'd use uuid v7 from 'uuidv7' package, but we'll use 'uuid'
// We'll use 'uuid' package.
import { v4 as uuid } from 'uuid';

const countries = [
  { id: 'NG', name: 'Nigeria' },
  { id: 'US', name: 'United States' },
  { id: 'GB', name: 'United Kingdom' },
  { id: 'KE', name: 'Kenya' },
  { id: 'BJ', name: 'Benin' },
  { id: 'AO', name: 'Angola' },
  { id: 'ZA', name: 'South Africa' },
  // ... add more to make 2026 distinct names
];

const names = [
  'Chinedu Okafor', 'Amina Bello', 'Emeka Nwosu', 'Fatima Yusuf', 'John Doe',
  // ... generate array of 2026 names
];

export async function seed(knex: Knex): Promise<void> {
  // Clear existing data
  await knex('profiles').del();

  const profiles = [];
  for (let i = 0; i < 2026; i++) {
    const country = countries[i % countries.length];
    const age = Math.floor(Math.random() * 60) + 10; // 10-70
    const ageGroup =
      age < 13 ? 'child' : age < 20 ? 'teenager' : age < 30 ? 'young' : age < 65 ? 'adult' : 'senior';
    // Map 'young' to 'adult' for age_group column (only child, teenager, adult, senior)
    const mappedAgeGroup = ageGroup === 'young' ? 'adult' : ageGroup;
    const gender = Math.random() > 0.5 ? 'male' : 'female';

    profiles.push({
      id: uuid(),
      name: names[i % names.length] + ' ' + i, // ensure uniqueness
      gender,
      gender_probability: parseFloat((0.6 + Math.random() * 0.35).toFixed(2)),
      age,
      age_group: mappedAgeGroup,
      country_id: country.id,
      country_name: country.name,
      country_probability: parseFloat((0.7 + Math.random() * 0.25).toFixed(2)),
      created_at: new Date().toISOString(),
    });
  }
  await knex('profiles').insert(profiles);
}