import { test, expect } from '@playwright/test';

test.describe('Habit Tracker app', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('shows the splash screen and redirects unauthenticated users to /login', async ({ page }) => {
    await expect(page.locator('[data-testid="splash-screen"]')).toBeVisible();
    await page.waitForURL(/\/login/);
    await expect(page.locator('[data-testid="auth-login-email"]')).toBeVisible();
  });

  test('redirects authenticated users from / to /dashboard', async ({ page }) => {
    await page.evaluate(() => {
      localStorage.setItem('habit-tracker-session', JSON.stringify({ userId: '1', email: 'a@b.com' }));
    });
    await page.goto('/');
    await page.waitForURL(/\/dashboard/);
    await expect(page.locator('[data-testid="dashboard-page"]')).toBeVisible();
  });

  test('prevents unauthenticated access to /dashboard', async ({ page }) => {
    await page.goto('/dashboard');
    await page.waitForURL(/\/login/);
    await expect(page).toHaveURL(/\/login/);
  });

  test('signs up a new user and lands on the dashboard', async ({ page }) => {
    await page.goto('/signup');
    await page.fill('[data-testid="auth-signup-email"]', 'newuser@test.com');
    await page.fill('[data-testid="auth-signup-password"]', 'password');
    await page.click('[data-testid="auth-signup-submit"]');
    await page.waitForURL(/\/dashboard/);
    await expect(page.locator('[data-testid="dashboard-page"]')).toBeVisible();
    const session = await page.evaluate(() => localStorage.getItem('habit-tracker-session'));
    expect(session).toBeTruthy();
  });

  test('logs in an existing user and loads only that user\'s habits', async ({ page }) => {
    await page.evaluate(() => {
      const users = [{ id: 'u1', email: 'login@test.com', password: 'pass', createdAt: new Date().toISOString() }];
      localStorage.setItem('habit-tracker-users', JSON.stringify(users));
      const habits = [
        { id: 'h1', userId: 'other', name: 'Other Habit', description: '', frequency: 'daily', createdAt: new Date().toISOString(), completions: [] }
      ];
      localStorage.setItem('habit-tracker-habits', JSON.stringify(habits));
    });
    await page.goto('/login');
    await page.fill('[data-testid="auth-login-email"]', 'login@test.com');
    await page.fill('[data-testid="auth-login-password"]', 'pass');
    await page.click('[data-testid="auth-login-submit"]');
    await page.waitForURL(/\/dashboard/);
    await expect(page.locator('[data-testid="habit-card-other-habit"]')).toHaveCount(0);
  });

  test('creates a habit from the dashboard', async ({ page }) => {
    await page.evaluate(() => {
      localStorage.setItem('habit-tracker-session', JSON.stringify({ userId: '1', email: 'a@b.com' }));
    });
    await page.goto('/dashboard');
    await page.click('[data-testid="create-habit-button"]');
    await page.fill('[data-testid="habit-name-input"]', 'Drink Water');
    await page.fill('[data-testid="habit-description-input"]', 'Stay hydrated');
    await page.click('[data-testid="habit-save-button"]');
    await expect(page.locator('[data-testid="habit-card-drink-water"]')).toBeVisible();
    await expect(page.locator('[data-testid="habit-streak-drink-water"]')).toContainText('0');
  });

  test('completes a habit for today and updates the streak', async ({ page }) => {
    const today = new Date().toISOString().slice(0, 10);
    await page.evaluate((date) => {
      localStorage.setItem('habit-tracker-session', JSON.stringify({ userId: '1', email: 'a@b.com' }));
      const habits = [{ id: 'h1', userId: '1', name: 'Run', description: '', frequency: 'daily', createdAt: new Date().toISOString(), completions: [] }];
      localStorage.setItem('habit-tracker-habits', JSON.stringify(habits));
    }, today);
    await page.goto('/dashboard');
    await page.click('[data-testid="habit-complete-run"]');
    await expect(page.locator('[data-testid="habit-streak-run"]')).toContainText('1');
  });

  test('persists session and habits after page reload', async ({ page }) => {
    await page.evaluate(() => {
      localStorage.setItem('habit-tracker-session', JSON.stringify({ userId: '1', email: 'persist@test.com' }));
    });
    await page.goto('/dashboard');
    await page.click('[data-testid="create-habit-button"]');
    await page.fill('[data-testid="habit-name-input"]', 'Persist Me');
    await page.click('[data-testid="habit-save-button"]');
    await expect(page.locator('[data-testid="habit-card-persist-me"]')).toBeVisible();
    await page.reload();
    await expect(page.locator('[data-testid="dashboard-page"]')).toBeVisible();
    await expect(page.locator('[data-testid="habit-card-persist-me"]')).toBeVisible();
  });

  test('logs out and redirects to /login', async ({ page }) => {
    await page.evaluate(() => {
      localStorage.setItem('habit-tracker-session', JSON.stringify({ userId: '1', email: 'logout@test.com' }));
    });
    await page.goto('/dashboard');
    await page.click('[data-testid="auth-logout-button"]');
    await page.waitForURL(/\/login/);
    const session = await page.evaluate(() => localStorage.getItem('habit-tracker-session'));
    expect(session).toBeNull();
  });

  test('loads the cached app shell when offline after the app has been loaded once', async ({ page }) => {
    await page.goto('/');
    await page.waitForSelector('[data-testid="splash-screen"]');
    await page.context().setOffline(true);
    await page.goto('/login');
    await expect(page.locator('[data-testid="auth-login-email"]')).toBeVisible();
  });
});