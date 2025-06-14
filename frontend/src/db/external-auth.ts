import { pgSchema, uuid } from 'drizzle-orm/pg-core';

// Minimal definition of the Supabase auth.users table so that
// foreign-key references in public tables compile. Do NOT add or
// modify columns here unless the primary-key definition in Supabase
// actually changes.

export const auth = pgSchema('auth');

export const usersInAuth = auth.table('users', {
  id: uuid().notNull(), // primary key only
}); 