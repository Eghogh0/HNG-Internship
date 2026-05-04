import knex from 'knex';
import { config } from '../config';

const db = knex({
  client: 'pg',
  connection: config.databaseUrl,
});

export async function findUserByGithubId(githubId: string) {
  return db('users').where('github_id', githubId).first();
}

export async function createUser(user: any) {
  return db('users').insert(user).returning('*');
}

export async function updateUser(id: string, updates: any) {
  return db('users').where('id', id).update(updates).returning('*');
}

export async function getUserById(id: string) {
  return db('users').where('id', id).first();
}

export async function invalidateRefreshToken(userId: string, token: string) {
  // Store refresh tokens in a separate table or as a field. For simplicity, we'll store hashed tokens.
  // We'll store refresh token hash in a `refresh_tokens` table.
  // Here we just assume a token revocation method.
  // We'll implement a refresh_tokens table.
  await db('refresh_tokens').where('user_id', userId).andWhere('token', token).del();
}

export async function saveRefreshToken(userId: string, token: string) {
  await db('refresh_tokens').insert({ user_id: userId, token, created_at: new Date() });
}

export async function verifyRefreshToken(userId: string, token: string) {
  const record = await db('refresh_tokens')
    .where('user_id', userId)
    .andWhere('token', token)
    .first();
  return !!record;
}