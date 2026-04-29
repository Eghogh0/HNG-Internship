'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { signupUser } from '@/lib/auth';

export default function SignupForm() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const result = signupUser(email, password);
    if (result.success) {
      router.push('/dashboard');
    } else {
      setError(result.error || 'Signup failed');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="w-full max-w-sm space-y-4 rounded bg-white p-6 shadow">
      <h2 className="text-2xl font-bold">Sign Up</h2>
      {error && <p className="text-red-500">{error}</p>}
      <div>
        <label htmlFor="signup-email" className="block text-sm font-medium">Email</label>
        <input id="signup-email" data-testid="auth-signup-email" type="email" required value={email}
          onChange={(e) => setEmail(e.target.value)} className="mt-1 w-full rounded border p-2" />
      </div>
      <div>
        <label htmlFor="signup-password" className="block text-sm font-medium">Password</label>
        <input id="signup-password" data-testid="auth-signup-password" type="password" required value={password}
          onChange={(e) => setPassword(e.target.value)} className="mt-1 w-full rounded border p-2" />
      </div>
      <button type="submit" data-testid="auth-signup-submit" className="w-full rounded bg-green-600 py-2 text-white hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500">Sign Up</button>
    </form>
  );
}