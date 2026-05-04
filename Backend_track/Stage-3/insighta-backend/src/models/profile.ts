import knex from 'knex';
import { config } from '../config';
import { v4 as uuid } from 'uuid';

const db = knex({ client: 'pg', connection: config.databaseUrl });

export async function getProfiles(filters: any, page: number, limit: number, sortBy = 'created_at', order = 'desc') {
  let query = db('profiles');
  // Apply filters
  if (filters.gender) query = query.where('gender', filters.gender);
  if (filters.age_group) query = query.where('age_group', filters.age_group);
  if (filters.country_id) query = query.where('country_id', filters.country_id.toUpperCase());
  if (filters.min_age) query = query.where('age', '>=', Number(filters.min_age));
  if (filters.max_age) query = query.where('age', '<=', Number(filters.max_age));
  if (filters.min_gender_probability) query = query.where('gender_probability', '>=', Number(filters.min_gender_probability));
  if (filters.min_country_probability) query = query.where('country_probability', '>=', Number(filters.min_country_probability));
  
  const totalQuery = query.clone().clearSelect().count('* as total').first();
  query = query.orderBy(sortBy, order).limit(limit).offset((page - 1) * limit);
  
  const [data, countResult] = await Promise.all([query, totalQuery]);
  return { data, total: Number((countResult as any).total) };
}

export async function getProfileById(id: string) {
  return db('profiles').where('id', id).first();
}

export async function createProfile(profile: any) {
  const [newProfile] = await db('profiles').insert({ id: uuid(), ...profile, created_at: new Date() }).returning('*');
  return newProfile;
}