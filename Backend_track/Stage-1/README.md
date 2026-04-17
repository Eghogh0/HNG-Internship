# Backend Wizards Stage 1

## Features
- Create profile using 3 external APIs
- Prevent duplicate names (idempotency)
- Store data in SQLite
- Filter profiles
- UUID v7 IDs
- ISO timestamps

## Endpoints

POST /api/profiles  
GET /api/profiles  
GET /api/profiles/:id  
DELETE /api/profiles/:id  

## Setup

```bash
npm install
npm start