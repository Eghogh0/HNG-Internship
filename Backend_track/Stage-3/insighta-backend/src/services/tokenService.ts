import jwt from 'jsonwebtoken';
import { v4 as uuid } from 'uuid';
import { config } from '../config';
import * as userModel from '../models/user';

export function generateAccessToken(userId: string, role: string) {
  return jwt.sign({ userId, role }, config.jwtSecret, { expiresIn: '3m' });
}

export async function generateRefreshToken(userId: string): Promise<string> {
  const token = uuid();
  // Store hashed token for security, but for simplicity we store raw
  await userModel.saveRefreshToken(userId, token);
  return token;
}

export async function refreshTokens(userId: string, oldRefreshToken: string) {
  const valid = await userModel.verifyRefreshToken(userId, oldRefreshToken);
  if (!valid) throw new Error('Invalid refresh token');
  await userModel.invalidateRefreshToken(userId, oldRefreshToken);
  const user = await userModel.getUserById(userId);
  if (!user || !user.is_active) throw new Error('User inactive');
  const accessToken = generateAccessToken(user.id, user.role);
  const newRefreshToken = await generateRefreshToken(user.id);
  return { access_token: accessToken, refresh_token: newRefreshToken };
}

export async function invalidateAllRefreshTokens(userId: string) {
  // Delete all refresh tokens for the user
  // Implementation: delete from refresh_tokens where user_id = userId
  // We'll add a method in model.
}