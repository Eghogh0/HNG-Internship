import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import LoginForm from '@/components/auth/LoginForm';
import SignupForm from '@/components/auth/SignupForm';

const mockPush = vi.fn();
vi.mock('next/navigation', () => ({
  useRouter: () => ({ push: mockPush }),
}));

describe('auth flow', () => {
  beforeEach(() => {
    localStorage.clear();
    mockPush.mockClear();
  });

  it('submits the signup form and creates a session', async () => {
    render(<SignupForm />);
    const user = userEvent.setup();
    await user.type(screen.getByTestId('auth-signup-email'), 'new@test.com');
    await user.type(screen.getByTestId('auth-signup-password'), 'password');
    await user.click(screen.getByTestId('auth-signup-submit'));
    await waitFor(() => {
      expect(localStorage.getItem('habit-tracker-session')).toBeTruthy();
      expect(mockPush).toHaveBeenCalledWith('/dashboard');
    });
  });

  it('shows an error for duplicate signup email', async () => {
    const existingUsers = [{ id: '1', email: 'dup@test.com', password: 'p', createdAt: new Date().toISOString() }];
    localStorage.setItem('habit-tracker-users', JSON.stringify(existingUsers));
    render(<SignupForm />);
    const user = userEvent.setup();
    await user.type(screen.getByTestId('auth-signup-email'), 'dup@test.com');
    await user.type(screen.getByTestId('auth-signup-password'), 'p');
    await user.click(screen.getByTestId('auth-signup-submit'));
    await waitFor(() => {
      expect(screen.getByText('User already exists')).toBeInTheDocument();
    });
  });

  it('submits the login form and stores the active session', async () => {
    const users = [{ id: '1', email: 'login@test.com', password: 'pass', createdAt: new Date().toISOString() }];
    localStorage.setItem('habit-tracker-users', JSON.stringify(users));
    render(<LoginForm />);
    const user = userEvent.setup();
    await user.type(screen.getByTestId('auth-login-email'), 'login@test.com');
    await user.type(screen.getByTestId('auth-login-password'), 'pass');
    await user.click(screen.getByTestId('auth-login-submit'));
    await waitFor(() => {
      const session = JSON.parse(localStorage.getItem('habit-tracker-session') || '{}');
      expect(session.email).toBe('login@test.com');
      expect(mockPush).toHaveBeenCalledWith('/dashboard');
    });
  });

  it('shows an error for invalid login credentials', async () => {
    render(<LoginForm />);
    const user = userEvent.setup();
    await user.type(screen.getByTestId('auth-login-email'), 'wrong@test.com');
    await user.type(screen.getByTestId('auth-login-password'), 'wrong');
    await user.click(screen.getByTestId('auth-login-submit'));
    await waitFor(() => {
      expect(screen.getByText('Invalid email or password')).toBeInTheDocument();
    });
  });
});