import 'dotenv/config';
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  out: './supabase/migrations',
  migrations: {
    prefix: 'timestamp',      // 👈  makes files like 20250614_add_updated_at.sql
  },
  schema: './frontend/src/db/schema.ts',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  schemaFilter: ["public"],
}); 