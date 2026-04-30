'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { loginUser } from '@/lib/auth';

export default function LoginForm() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const result = loginUser(email, password);
    if (result.success) {
      router.push('/dashboard');
    } else {
      setError(result.error || 'Invalid email or password');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="w-full max-w-sm space-y-4 rounded bg-white p-6 shadow">
      <h2 className="text-2xl font-bold">Login</h2>
      {error && <p className="text-red-500">{error}</p>}
      <div>
        <label htmlFor="login-email" className="block text-sm font-medium">Email</label>
        <input id="login-email" data-testid="auth-login-email" type="email" required value={email}
          onChange={(e) => setEmail(e.target.value)} className="mt-1 w-full rounded border p-2" />
      </div>
      <div>
        <label htmlFor="login-password" className="block text-sm font-medium">Password</label>
        <input id="login-password" data-testid="auth-login-password" type="password" required value={password}
          onChange={(e) => setPassword(e.target.value)} className="mt-1 w-full rounded border p-2" />
      </div>
      <button type="submit" data-testid="auth-login-submit" className="w-full rounded bg-blue-600 py-2 text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">Login</button>
    </form>
  );
}