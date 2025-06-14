import { pgTable, foreignKey, pgPolicy, uuid, text, timestamp, unique, boolean, integer, date, check, index, jsonb, uniqueIndex, bigint, numeric, doublePrecision, primaryKey, pgView } from "drizzle-orm/pg-core"
import { sql } from "drizzle-orm"

import { pgSchema } from 'drizzle-orm/pg-core';

// Minimal definition of the Supabase auth.users table so that
// foreign-key references in public tables compile. Do NOT add or
// modify columns here unless the primary-key definition in Supabase
// actually changes.

export const auth = pgSchema('auth');

export const usersInAuth = auth.table('users', {
  id: uuid().notNull(), // primary key only
}); 

export const features = pgTable("features", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	title: text().notNull(),
	description: text(),
	status: text().default('Open'),
	createdBy: uuid("created_by"),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow(),
}, (table) => [
	foreignKey({
			columns: [table.createdBy],
			foreignColumns: [usersInAuth.id],
			name: "features_created_by_fkey"
		}).onDelete("set null"),
	pgPolicy("Admins can delete", { as: "permissive", for: "delete", to: ["public"], using: sql`has_role('admin'::text)` }),
	pgPolicy("Admins can insert", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Admins can read", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Admins can update", { as: "permissive", for: "update", to: ["public"] }),
	pgPolicy("Authenticated users can read features", { as: "permissive", for: "select", to: ["authenticated"] }),
]);

export const artistPlacements = pgTable("artist_placements", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	userId: uuid("user_id"),
	artistId: uuid("artist_id"),
	stage: text(),
	tier: text(),
	insertedAt: timestamp("inserted_at", { withTimezone: true, mode: 'string' }),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow(),
	isAdminPlacement: boolean("is_admin_placement").default(false),
}, (table) => [
	foreignKey({
			columns: [table.artistId],
			foreignColumns: [artists.id],
			name: "artist_placements_artist_id_fkey"
		}),
	foreignKey({
			columns: [table.userId],
			foreignColumns: [usersInAuth.id],
			name: "artist_placements_user_id_fkey"
		}),
	unique("unique_user_artist").on(table.userId, table.artistId),
	pgPolicy("Admins can delete", { as: "permissive", for: "delete", to: ["public"], using: sql`has_role('admin'::text)` }),
	pgPolicy("Admins can insert", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Admins can read", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Admins can update", { as: "permissive", for: "update", to: ["public"] }),
	pgPolicy("Allow user to insert their own placements", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Allow user to update their own placements", { as: "permissive", for: "update", to: ["public"] }),
	pgPolicy("Allow user to view their own placements", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Users can delete their own placements", { as: "permissive", for: "delete", to: ["authenticated"] }),
]);

export const eventSets = pgTable("event_sets", {
	eventId: uuid("event_id").notNull(),
	tier: integer().default(1).notNull(),
	setNote: text("set_note"),
	displayName: text("display_name"),
	createdBy: uuid("created_by"),
	id: uuid().defaultRandom().primaryKey().notNull(),
}, (table) => [
	foreignKey({
			columns: [table.eventId],
			foreignColumns: [events.id],
			name: "event_lineups_event_id_fkey"
		}).onDelete("cascade"),
	pgPolicy("Admins can delete", { as: "permissive", for: "delete", to: ["public"], using: sql`has_role('admin'::text)` }),
	pgPolicy("Admins can insert", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Admins can read", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Admins can update", { as: "permissive", for: "update", to: ["public"] }),
	pgPolicy("All users can read lineups", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Public can delete event lineups", { as: "permissive", for: "delete", to: ["public"] }),
	pgPolicy("Public can insert event lineups", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Public can read all event lineups", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Public can update event lineups", { as: "permissive", for: "update", to: ["public"] }),
]);

export const featureVotes = pgTable("feature_votes", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	featureId: uuid("feature_id"),
	userId: uuid("user_id"),
	votedAt: timestamp("voted_at", { withTimezone: true, mode: 'string' }).defaultNow(),
}, (table) => [
	foreignKey({
			columns: [table.featureId],
			foreignColumns: [features.id],
			name: "feature_votes_feature_id_fkey"
		}).onDelete("cascade"),
	foreignKey({
			columns: [table.userId],
			foreignColumns: [usersInAuth.id],
			name: "feature_votes_user_id_fkey"
		}).onDelete("cascade"),
	unique("feature_votes_feature_id_user_id_key").on(table.featureId, table.userId),
	pgPolicy("Admins can delete", { as: "permissive", for: "delete", to: ["public"], using: sql`has_role('admin'::text)` }),
	pgPolicy("Admins can insert", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Admins can read", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Admins can update", { as: "permissive", for: "update", to: ["public"] }),
	pgPolicy("Authenticated users can insert their own votes", { as: "permissive", for: "insert", to: ["authenticated"] }),
	pgPolicy("Authenticated users can read feature votes", { as: "permissive", for: "select", to: ["authenticated"] }),
]);

export const events = pgTable("events", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	name: text().notNull(),
	date: date(),
	location: text(),
	createdBy: uuid("created_by"),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow(),
	numTiers: integer("num_tiers").default(3).notNull(),
	slug: text(),
	isDraft: boolean("is_draft").default(true),
	status: text().default('draft'),
}, (table) => [
	foreignKey({
			columns: [table.createdBy],
			foreignColumns: [usersInAuth.id],
			name: "events_created_by_fkey"
		}),
	unique("events_slug_key").on(table.slug),
	pgPolicy("Admins can delete", { as: "permissive", for: "delete", to: ["public"], using: sql`has_role('admin'::text)` }),
	pgPolicy("Admins can insert", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Admins can read", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Admins can update", { as: "permissive", for: "update", to: ["public"] }),
	pgPolicy("Anyone can read published events", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Public can delete events", { as: "permissive", for: "delete", to: ["public"] }),
	pgPolicy("Public can insert events", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Public can read all events", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Public can update events", { as: "permissive", for: "update", to: ["public"] }),
]);

export const artistPlacementHistory = pgTable("artist_placement_history", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	userId: uuid("user_id").notNull(),
	artistId: uuid("artist_id").notNull(),
	tier: text().notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow(),
}, (table) => [
	foreignKey({
			columns: [table.artistId],
			foreignColumns: [artists.id],
			name: "artist_placement_history_artist_id_fkey"
		}),
	foreignKey({
			columns: [table.userId],
			foreignColumns: [usersInAuth.id],
			name: "artist_placement_history_user_id_fkey"
		}),
	pgPolicy("Admins can delete", { as: "permissive", for: "delete", to: ["public"], using: sql`has_role('admin'::text)` }),
	pgPolicy("Admins can insert", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Admins can read", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Admins can update", { as: "permissive", for: "update", to: ["public"] }),
	pgPolicy("Allow user to insert their own placement history", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Allow user to update their own placement history", { as: "permissive", for: "update", to: ["public"] }),
]);

export const profiles = pgTable("profiles", {
	id: uuid().primaryKey().notNull(),
	username: text(),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow(),
	bio: text(),
}, (table) => [
	foreignKey({
			columns: [table.id],
			foreignColumns: [usersInAuth.id],
			name: "profiles_id_fkey"
		}).onDelete("cascade"),
	unique("profiles_username_key").on(table.username),
	pgPolicy("Anyone can get display names", { as: "permissive", for: "select", to: ["public"], using: sql`true` }),
	pgPolicy("Public profiles are viewable by everyone.", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Users can update own profile.", { as: "permissive", for: "update", to: ["public"] }),
	check("username_format", sql`(username IS NULL) OR ((length(username) >= 3) AND (length(username) <= 30) AND (username ~ '^[a-zA-Z0-9 _-]+$'::text) AND (TRIM(BOTH FROM username) <> ''::text))`),
]);

export const userActivities = pgTable("user_activities", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	userId: uuid("user_id").notNull(),
	activityType: text("activity_type").notNull(),
	artistId: uuid("artist_id"),
	eventId: uuid("event_id"),
	setId: uuid("set_id"),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow(),
	metadata: jsonb().default({}),
}, (table) => [
	index("idx_user_activities_artist_id").using("btree", table.artistId.asc().nullsLast().op("uuid_ops")),
	index("idx_user_activities_event_id").using("btree", table.eventId.asc().nullsLast().op("uuid_ops")),
	index("idx_user_activities_user_id").using("btree", table.userId.asc().nullsLast().op("uuid_ops")),
	index("user_activities_activity_type_idx").using("btree", table.activityType.asc().nullsLast().op("text_ops")),
	index("user_activities_created_at_idx").using("btree", table.createdAt.asc().nullsLast().op("timestamptz_ops")),
	foreignKey({
			columns: [table.artistId],
			foreignColumns: [artists.id],
			name: "user_activities_artist_id_fkey"
		}),
	foreignKey({
			columns: [table.eventId],
			foreignColumns: [events.id],
			name: "user_activities_event_id_fkey"
		}),
	foreignKey({
			columns: [table.setId],
			foreignColumns: [eventSets.id],
			name: "user_activities_set_id_fkey"
		}).onDelete("cascade"),
	foreignKey({
			columns: [table.userId],
			foreignColumns: [usersInAuth.id],
			name: "user_activities_user_id_fkey"
		}),
	pgPolicy("Activities are viewable by all users", { as: "permissive", for: "select", to: ["authenticated"], using: sql`true` }),
	pgPolicy("Activities can only be inserted by the system", { as: "permissive", for: "insert", to: ["authenticated"] }),
	pgPolicy("Admins can view all activities", { as: "permissive", for: "select", to: ["authenticated"] }),
	pgPolicy("Users can insert their own activities", { as: "permissive", for: "insert", to: ["authenticated"] }),
	pgPolicy("Users can view their own activities", { as: "permissive", for: "select", to: ["authenticated"] }),
]);

export const artists = pgTable("artists", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
	name: text(),
	createdBy: uuid("created_by"),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow(),
	type: text().default('solo').notNull(),
	fingerprint: text(),
}, (table) => [
	uniqueIndex("unique_upper_artist_name").using("btree", sql`upper(name)`),
	foreignKey({
			columns: [table.createdBy],
			foreignColumns: [usersInAuth.id],
			name: "artists_created_by_fkey"
		}),
	pgPolicy("Admins can delete", { as: "permissive", for: "delete", to: ["public"], using: sql`has_role('admin'::text)` }),
	pgPolicy("Admins can insert", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Admins can read", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Admins can update", { as: "permissive", for: "update", to: ["public"] }),
	pgPolicy("All users can read artists", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Allow authenticated artist creation", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("Enable read access for all users", { as: "permissive", for: "select", to: ["public"] }),
]);

export const userLevels = pgTable("user_levels", {
	userId: uuid("user_id").primaryKey().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	xpOverflow: bigint("xp_overflow", { mode: "number" }).default(0),
	prestigeLevel: integer("prestige_level").default(0),
	prestigeMultiplier: numeric("prestige_multiplier", { precision: 10, scale:  2 }).default('1.0'),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	totalXpEarned: bigint("total_xp_earned", { mode: "number" }).default(0),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow(),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }).defaultNow(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	currentLevel: bigint("current_level", { mode: "number" }).generatedAlwaysAs(sql`
CASE
    WHEN (total_xp_earned = 0) THEN (1)::bigint
    ELSE ((total_xp_earned / 5000) + 1)
END`),
}, (table) => [
	foreignKey({
			columns: [table.userId],
			foreignColumns: [usersInAuth.id],
			name: "user_levels_user_id_fkey"
		}),
	pgPolicy("Users can insert their own levels", { as: "permissive", for: "insert", to: ["authenticated"], withCheck: sql`(auth.uid() = user_id)`  }),
	pgPolicy("Users can update their own levels", { as: "permissive", for: "update", to: ["authenticated"] }),
	pgPolicy("Users can view their own levels", { as: "permissive", for: "select", to: ["authenticated"] }),
]);

export const xpConfig = pgTable("xp_config", {
	activityType: text("activity_type").primaryKey().notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	baseXp: bigint("base_xp", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	xpPerLevel: bigint("xp_per_level", { mode: "number" }).default(5000).notNull(),
	chaosMin: doublePrecision("chaos_min").default(0.7).notNull(),
	chaosMax: doublePrecision("chaos_max").default(1.3).notNull(),
	critChance: doublePrecision("crit_chance").default(0.05).notNull(),
	critMultiplier: doublePrecision("crit_multiplier").default(2).notNull(),
});

export const roles = pgTable("roles", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	userId: uuid("user_id"),
	role: text(),
}, (table) => [
	foreignKey({
			columns: [table.userId],
			foreignColumns: [usersInAuth.id],
			name: "roles_user_id_fkey"
		}).onDelete("cascade"),
	unique("roles_user_id_role_key").on(table.userId, table.role),
	check("roles_role_check", sql`role = ANY (ARRAY['admin'::text, 'fan'::text, 'artist'::text, 'promoter'::text])`),
]);

export const xpRewards = pgTable("xp_rewards", {
	id: uuid().defaultRandom().primaryKey().notNull(),
	userId: uuid("user_id"),
	activityType: text("activity_type").notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	baseXp: bigint("base_xp", { mode: "number" }).notNull(),
	chaosMultiplier: numeric("chaos_multiplier", { precision: 10, scale:  2 }).notNull(),
	critMultiplier: numeric("crit_multiplier", { precision: 10, scale:  2 }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	totalXpEarned: bigint("total_xp_earned", { mode: "number" }).notNull(),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	levelsGained: bigint("levels_gained", { mode: "number" }).notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow(),
	sourceValid: boolean("source_valid").default(true),
}, (table) => [
	index("idx_xp_rewards_created_at").using("btree", table.createdAt.desc().nullsFirst().op("timestamptz_ops")),
	index("idx_xp_rewards_user_id").using("btree", table.userId.asc().nullsLast().op("uuid_ops")),
	foreignKey({
			columns: [table.userId],
			foreignColumns: [usersInAuth.id],
			name: "xp_rewards_user_id_fkey"
		}),
	pgPolicy("Users can insert their own rewards", { as: "permissive", for: "insert", to: ["authenticated"], withCheck: sql`(auth.uid() = user_id)`  }),
	pgPolicy("Users can view their own rewards", { as: "permissive", for: "select", to: ["authenticated"] }),
]);

export const artistMembers = pgTable("artist_members", {
	parentArtistId: uuid("parent_artist_id").notNull(),
	memberArtistId: uuid("member_artist_id").notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow(),
}, (table) => [
	index("idx_artist_members_member").using("btree", table.memberArtistId.asc().nullsLast().op("uuid_ops")),
	index("idx_artist_members_parent").using("btree", table.parentArtistId.asc().nullsLast().op("uuid_ops")),
	foreignKey({
			columns: [table.memberArtistId],
			foreignColumns: [artists.id],
			name: "artist_members_member_artist_id_fkey"
		}).onDelete("cascade"),
	foreignKey({
			columns: [table.parentArtistId],
			foreignColumns: [artists.id],
			name: "artist_members_parent_artist_id_fkey"
		}).onDelete("cascade"),
	primaryKey({ columns: [table.parentArtistId, table.memberArtistId], name: "artist_members_pkey"}),
	pgPolicy("Enable delete for authenticated users only", { as: "permissive", for: "delete", to: ["authenticated"], using: sql`true` }),
	pgPolicy("Enable insert for authenticated users only", { as: "permissive", for: "insert", to: ["authenticated"] }),
	pgPolicy("Enable read access for all users", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("Enable update for authenticated users only", { as: "permissive", for: "update", to: ["authenticated"] }),
]);

export const eventSetArtists = pgTable("event_set_artists", {
	setId: uuid("set_id").notNull(),
	artistId: uuid("artist_id").notNull(),
	eventId: uuid("event_id"),
}, (table) => [
	foreignKey({
			columns: [table.artistId],
			foreignColumns: [artists.id],
			name: "event_lineup_artists_artist_id_fkey"
		}).onDelete("cascade"),
	foreignKey({
			columns: [table.setId],
			foreignColumns: [eventSets.id],
			name: "event_lineup_artists_lineup_id_fkey"
		}).onDelete("cascade"),
	primaryKey({ columns: [table.setId, table.artistId], name: "event_lineup_artists_pkey"}),
	pgPolicy("All users can delete lineup artists", { as: "permissive", for: "delete", to: ["public"], using: sql`true` }),
	pgPolicy("All users can insert lineup artists", { as: "permissive", for: "insert", to: ["public"] }),
	pgPolicy("All users can read lineup artists", { as: "permissive", for: "select", to: ["public"] }),
	pgPolicy("All users can update lineup artists", { as: "permissive", for: "update", to: ["public"] }),
]);

export const firstTimeRankings = pgTable("first_time_rankings", {
	userId: uuid("user_id").notNull(),
	artistId: uuid("artist_id").notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
}, (table) => [
	index("idx_first_time_rankings_user").using("btree", table.userId.asc().nullsLast().op("uuid_ops")),
	foreignKey({
			columns: [table.artistId],
			foreignColumns: [artists.id],
			name: "first_time_rankings_artist_id_fkey"
		}).onDelete("cascade"),
	foreignKey({
			columns: [table.userId],
			foreignColumns: [usersInAuth.id],
			name: "first_time_rankings_user_id_fkey"
		}).onDelete("cascade"),
	primaryKey({ columns: [table.userId, table.artistId], name: "first_time_rankings_pkey"}),
]);

export const activityRewards = pgTable("activity_rewards", {
	activityId: uuid("activity_id").notNull(),
	rewardId: uuid("reward_id").notNull(),
	createdAt: timestamp("created_at", { withTimezone: true, mode: 'string' }).defaultNow().notNull(),
}, (table) => [
	index("idx_activity_rewards_activity").using("btree", table.activityId.asc().nullsLast().op("uuid_ops")),
	index("idx_activity_rewards_reward").using("btree", table.rewardId.asc().nullsLast().op("uuid_ops")),
	foreignKey({
			columns: [table.activityId],
			foreignColumns: [userActivities.id],
			name: "activity_rewards_activity_id_fkey"
		}).onDelete("cascade"),
	foreignKey({
			columns: [table.rewardId],
			foreignColumns: [xpRewards.id],
			name: "activity_rewards_reward_id_fkey"
		}).onDelete("cascade"),
	primaryKey({ columns: [table.activityId, table.rewardId], name: "activity_rewards_pkey"}),
	unique("activity_rewards_activity_id_key").on(table.activityId),
	unique("activity_rewards_reward_id_key").on(table.rewardId),
]);
export const eventSetsView = pgView("event_sets_view", {	setId: uuid("set_id"),
	eventId: uuid("event_id"),
	tier: integer(),
	displayName: text("display_name"),
	setNote: text("set_note"),
	artistId: uuid("artist_id"),
	artistName: text("artist_name"),
	type: text(),
}).as(sql`SELECT s.id AS set_id, s.event_id, s.tier, s.display_name, s.set_note, a.id AS artist_id, a.name AS artist_name, a.type FROM event_sets s JOIN event_set_artists esa ON esa.set_id = s.id JOIN artists a ON a.id = esa.artist_id`);

export const artistContributions = pgView("artist_contributions", {	artistId: uuid("artist_id"),
	artistName: text("artist_name"),
	userId: uuid("user_id"),
	contributorName: text("contributor_name"),
	activityType: text("activity_type"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	contributionCount: bigint("contribution_count", { mode: "number" }),
}).as(sql`SELECT a.id AS artist_id, a.name AS artist_name, ua.user_id, u.raw_user_meta_data ->> 'full_name'::text AS contributor_name, ua.activity_type, count(*) AS contribution_count FROM artists a JOIN user_activities ua ON ua.artist_id = a.id JOIN auth.users u ON ua.user_id = u.id GROUP BY a.id, a.name, ua.user_id, (u.raw_user_meta_data ->> 'full_name'::text), ua.activity_type`);

export const userTotalXp = pgView("user_total_xp", {	userId: uuid("user_id"),
	// You can use { mode: "bigint" } if numbers are exceeding js number limitations
	totalXp: bigint("total_xp", { mode: "number" }),
}).as(sql`SELECT xp_rewards.user_id, COALESCE(sum(xp_rewards.total_xp_earned), 0::numeric)::bigint AS total_xp FROM xp_rewards GROUP BY xp_rewards.user_id`);

export const artistPlacementsWithNames = pgView("artist_placements_with_names", {	id: uuid(),
	userId: uuid("user_id"),
	artistId: uuid("artist_id"),
	artistName: text("artist_name"),
	tier: text(),
	updatedAt: timestamp("updated_at", { withTimezone: true, mode: 'string' }),
}).as(sql`SELECT ap.id, ap.user_id, ap.artist_id, a.name AS artist_name, ap.tier, ap.updated_at FROM artist_placements ap JOIN artists a ON ap.artist_id = a.id`);