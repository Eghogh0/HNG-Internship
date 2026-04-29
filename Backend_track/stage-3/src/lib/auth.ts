import { User, Session } from '@/types/auth';
import { STORAGE_KEYS } from './constants';
import { getItem, setItem, removeItem } from './storage';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substr(2, 9);
}

export function signupUser(email: string, password: string): { success: boolean; error?: string } {
  const users: User[] = getItem<User[]>(STORAGE_KEYS.USERS) || [];
  const existing = users.find(u => u.email === email);
  if (existing) {
    return { success: false, error: 'User already exists' };
  }
  const newUser: User = {
    id: generateId(),
    email,
    password,
    createdAt: new Date().toISOString(),
  };
  users.push(newUser);
  setItem(STORAGE_KEYS.USERS, users);
  const session: Session = { userId: newUser.id, email: newUser.email };
  setItem(STORAGE_KEYS.SESSION, session);
  return { success: true };
}

export function loginUser(email: string, password: string): { success: boolean; error?: string } {
  const users: User[] = getItem<User[]>(STORAGE_KEYS.USERS) || [];
  const user = users.find(u => u.email === email && u.password === password);
  if (!user) {
    return { success: false, error: 'Invalid email or password' };
  }
  const session: Session = { userId: user.id, email: user.email };
  setItem(STORAGE_KEYS.SESSION, session);
  return { success: true };
}

export function getSession(): Session | null {
  return getItem<Session>(STORAGE_KEYS.SESSION);
}

export function logout(): void {
  removeItem(STORAGE_KEYS.SESSION);
}