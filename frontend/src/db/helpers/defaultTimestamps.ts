import { timestamp } from "drizzle-orm/pg-core";

/**
 * Returns default timestamp columns for Drizzle tables:
 * - createdAt: timestamptz, default now()
 * - updatedAt: timestamptz, default now(), $onUpdate to auto-update on row update
 */
export function defaultTimestamps() {
  return {
    createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow().$onUpdate(() => new Date().toISOString()),
  };
} 