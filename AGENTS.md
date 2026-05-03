---
description: Instructions building apps with MCP
globs: *
alwaysApply: true
---

# Supabase Documentation - Overview

## What is Supabase?

Backend-as-a-service (BaaS) platform providing:

- **Database**: PostgreSQL with PostgREST API
- **Authentication**: Email/password + OAuth (Google, GitHub)
- **Storage**: File upload/download
- **Edge Functions**: Serverless function deployment
- **Realtime**: WebSocket pub/sub for database changes and client events

## SDK Integration

The project uses `supabase_flutter` for all backend interactions.

### Initialization
Supabase is initialized in `main.dart` using credentials from the `.env` file:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Core Modules
- **Auth**: Handled by `AuthProvider` using `supabase.auth`.
- **Database**: CRUD operations using `supabase.from('table_name')`.
- **Realtime**: Listen to changes using `.stream()` or `.onPostgresChanges()`.
- **Storage**: File management via `supabase.storage`.

## Important Notes
- Always use RLS (Row Level Security) to protect data.
- All database calls are asynchronous.
- For Realtime notifications, ensure the table has "Realtime" enabled in the Supabase Dashboard.