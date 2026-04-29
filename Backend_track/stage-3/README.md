# Habit Tracker PWA - Stage 3

## Overview
A mobile-first Habit Tracker Progressive Web App built to exact technical specifications.

## Setup Instructions
1. Clone repository and enter the folder.
2. Run `npm install`
3. Run `node generate-icons.js` to create placeholder icons.
4. Run `npm run dev` to start development server.

## Run Instructions
- Development: `npm run dev`
- Build: `npm run build`
- Start production: `npm start`

## Test Instructions
- Unit tests: `npm run test:unit`
- Integration tests: `npm run test:integration`
- E2E tests: `npm run test:e2e` (requires Playwright browsers installed; run `npx playwright install` first)
- All tests: `npm test`

## Local Persistence Structure
Data stored in `localStorage` using three keys:
- `habit-tracker-users`: Array of User objects
- `habit-tracker-session`: null or Session object
- `habit-tracker-habits`: Array of Habit objects
All operations deterministic and local.

## PWA Implementation
- `manifest.json` for installable metadata.
- `sw.js` caches the app shell routes.
- Service worker registered in the root layout.

## Test File Mapping
| Test File | Behavior Verified |
|-----------|-------------------|
| `tests/unit/slug.test.ts` | Slug generation (case, spaces, invalid chars) |
| `tests/unit/validators.test.ts` | Habit name validation (empty, length, trimming) |
| `tests/unit/streaks.test.ts` | Streak calculation (empty, non-consecutive, duplicates) |
| `tests/unit/habits.test.ts` | Completion toggle (add, remove, immutability, duplicates) |
| `tests/integration/auth-flow.test.tsx` | Auth flow (signup, login, error handling, session) |
| `tests/integration/habit-form.test.tsx` | Habit form CRUD, validation, streak update |
| `tests/e2e/app.spec.ts` | Full user journeys (splash, auth, dashboard, offline) |

## Assumptions / Trade-offs
- Authentication is local and not secure for production.
- Icons are solid color placeholders, replace with real assets.
- Service worker caches only the shell; dynamic pages cached on navigation.
- Only 'daily' frequency supported.
- The project uses Next.js App Router, as required.