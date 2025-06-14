-- Current sql file was generated after introspecting the database
-- If you want to run this migration please uncomment this code before executing migrations
/*
CREATE TABLE "features" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"title" text NOT NULL,
	"description" text,
	"status" text DEFAULT 'Open',
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "features" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "artist_placements" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"user_id" uuid,
	"artist_id" uuid,
	"stage" text,
	"tier" text,
	"inserted_at" timestamp with time zone,
	"updated_at" timestamp with time zone DEFAULT now(),
	"is_admin_placement" boolean DEFAULT false,
	CONSTRAINT "unique_user_artist" UNIQUE("user_id","artist_id")
);
--> statement-breakpoint
ALTER TABLE "artist_placements" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "event_sets" (
	"event_id" uuid NOT NULL,
	"tier" integer DEFAULT 1 NOT NULL,
	"set_note" text,
	"display_name" text,
	"created_by" uuid,
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "event_sets" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "feature_votes" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"feature_id" uuid,
	"user_id" uuid,
	"voted_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "feature_votes_feature_id_user_id_key" UNIQUE("feature_id","user_id")
);
--> statement-breakpoint
ALTER TABLE "feature_votes" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"date" date,
	"location" text,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now(),
	"num_tiers" integer DEFAULT 3 NOT NULL,
	"slug" text,
	"is_draft" boolean DEFAULT true,
	"status" text DEFAULT 'draft',
	CONSTRAINT "events_slug_key" UNIQUE("slug")
);
--> statement-breakpoint
ALTER TABLE "events" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "artist_placement_history" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"artist_id" uuid NOT NULL,
	"tier" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "artist_placement_history" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "profiles" (
	"id" uuid PRIMARY KEY NOT NULL,
	"username" text,
	"updated_at" timestamp with time zone DEFAULT now(),
	"bio" text,
	CONSTRAINT "profiles_username_key" UNIQUE("username"),
	CONSTRAINT "username_format" CHECK ((username IS NULL) OR ((length(username) >= 3) AND (length(username) <= 30) AND (username ~ '^[a-zA-Z0-9 _-]+$'::text) AND (TRIM(BOTH FROM username) <> ''::text)))
);
--> statement-breakpoint
ALTER TABLE "profiles" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "user_activities" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"activity_type" text NOT NULL,
	"artist_id" uuid,
	"event_id" uuid,
	"set_id" uuid,
	"created_at" timestamp with time zone DEFAULT now(),
	"metadata" jsonb DEFAULT '{}'::jsonb
);
--> statement-breakpoint
ALTER TABLE "user_activities" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "artists" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"name" text,
	"created_by" uuid,
	"updated_at" timestamp with time zone DEFAULT now(),
	"type" text DEFAULT 'solo' NOT NULL,
	"fingerprint" text
);
--> statement-breakpoint
ALTER TABLE "artists" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "user_levels" (
	"user_id" uuid PRIMARY KEY NOT NULL,
	"xp_overflow" bigint DEFAULT 0,
	"prestige_level" integer DEFAULT 0,
	"prestige_multiplier" numeric(10, 2) DEFAULT '1.0',
	"total_xp_earned" bigint DEFAULT 0,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	"current_level" bigint GENERATED ALWAYS AS (
CASE
    WHEN (total_xp_earned = 0) THEN (1)::bigint
    ELSE ((total_xp_earned / 5000) + 1)
END) STORED
);
--> statement-breakpoint
ALTER TABLE "user_levels" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "xp_config" (
	"activity_type" text PRIMARY KEY NOT NULL,
	"base_xp" bigint NOT NULL,
	"xp_per_level" bigint DEFAULT 5000 NOT NULL,
	"chaos_min" double precision DEFAULT 0.7 NOT NULL,
	"chaos_max" double precision DEFAULT 1.3 NOT NULL,
	"crit_chance" double precision DEFAULT 0.05 NOT NULL,
	"crit_multiplier" double precision DEFAULT 2 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "roles" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"role" text,
	CONSTRAINT "roles_user_id_role_key" UNIQUE("user_id","role"),
	CONSTRAINT "roles_role_check" CHECK (role = ANY (ARRAY['admin'::text, 'fan'::text, 'artist'::text, 'promoter'::text]))
);
--> statement-breakpoint
CREATE TABLE "xp_rewards" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid,
	"activity_type" text NOT NULL,
	"base_xp" bigint NOT NULL,
	"chaos_multiplier" numeric(10, 2) NOT NULL,
	"crit_multiplier" numeric(10, 2) NOT NULL,
	"total_xp_earned" bigint NOT NULL,
	"levels_gained" bigint NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"source_valid" boolean DEFAULT true
);
--> statement-breakpoint
ALTER TABLE "xp_rewards" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "artist_members" (
	"parent_artist_id" uuid NOT NULL,
	"member_artist_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "artist_members_pkey" PRIMARY KEY("parent_artist_id","member_artist_id")
);
--> statement-breakpoint
ALTER TABLE "artist_members" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "event_set_artists" (
	"set_id" uuid NOT NULL,
	"artist_id" uuid NOT NULL,
	"event_id" uuid,
	CONSTRAINT "event_lineup_artists_pkey" PRIMARY KEY("set_id","artist_id")
);
--> statement-breakpoint
ALTER TABLE "event_set_artists" ENABLE ROW LEVEL SECURITY;--> statement-breakpoint
CREATE TABLE "first_time_rankings" (
	"user_id" uuid NOT NULL,
	"artist_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "first_time_rankings_pkey" PRIMARY KEY("user_id","artist_id")
);
--> statement-breakpoint
CREATE TABLE "activity_rewards" (
	"activity_id" uuid NOT NULL,
	"reward_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "activity_rewards_pkey" PRIMARY KEY("activity_id","reward_id"),
	CONSTRAINT "activity_rewards_activity_id_key" UNIQUE("activity_id"),
	CONSTRAINT "activity_rewards_reward_id_key" UNIQUE("reward_id")
);
--> statement-breakpoint
ALTER TABLE "features" ADD CONSTRAINT "features_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "artist_placements" ADD CONSTRAINT "artist_placements_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "public"."artists"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "artist_placements" ADD CONSTRAINT "artist_placements_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_sets" ADD CONSTRAINT "event_lineups_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "feature_votes" ADD CONSTRAINT "feature_votes_feature_id_fkey" FOREIGN KEY ("feature_id") REFERENCES "public"."features"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "feature_votes" ADD CONSTRAINT "feature_votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "events" ADD CONSTRAINT "events_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "artist_placement_history" ADD CONSTRAINT "artist_placement_history_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "public"."artists"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "artist_placement_history" ADD CONSTRAINT "artist_placement_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "profiles" ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_activities" ADD CONSTRAINT "user_activities_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "public"."artists"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_activities" ADD CONSTRAINT "user_activities_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."events"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_activities" ADD CONSTRAINT "user_activities_set_id_fkey" FOREIGN KEY ("set_id") REFERENCES "public"."event_sets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_activities" ADD CONSTRAINT "user_activities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "artists" ADD CONSTRAINT "artists_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_levels" ADD CONSTRAINT "user_levels_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "roles" ADD CONSTRAINT "roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "xp_rewards" ADD CONSTRAINT "xp_rewards_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "artist_members" ADD CONSTRAINT "artist_members_member_artist_id_fkey" FOREIGN KEY ("member_artist_id") REFERENCES "public"."artists"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "artist_members" ADD CONSTRAINT "artist_members_parent_artist_id_fkey" FOREIGN KEY ("parent_artist_id") REFERENCES "public"."artists"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_set_artists" ADD CONSTRAINT "event_lineup_artists_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "public"."artists"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_set_artists" ADD CONSTRAINT "event_lineup_artists_lineup_id_fkey" FOREIGN KEY ("set_id") REFERENCES "public"."event_sets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "first_time_rankings" ADD CONSTRAINT "first_time_rankings_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "public"."artists"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "first_time_rankings" ADD CONSTRAINT "first_time_rankings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "activity_rewards" ADD CONSTRAINT "activity_rewards_activity_id_fkey" FOREIGN KEY ("activity_id") REFERENCES "public"."user_activities"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "activity_rewards" ADD CONSTRAINT "activity_rewards_reward_id_fkey" FOREIGN KEY ("reward_id") REFERENCES "public"."xp_rewards"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_user_activities_artist_id" ON "user_activities" USING btree ("artist_id" uuid_ops);--> statement-breakpoint
CREATE INDEX "idx_user_activities_event_id" ON "user_activities" USING btree ("event_id" uuid_ops);--> statement-breakpoint
CREATE INDEX "idx_user_activities_user_id" ON "user_activities" USING btree ("user_id" uuid_ops);--> statement-breakpoint
CREATE INDEX "user_activities_activity_type_idx" ON "user_activities" USING btree ("activity_type" text_ops);--> statement-breakpoint
CREATE INDEX "user_activities_created_at_idx" ON "user_activities" USING btree ("created_at" timestamptz_ops);--> statement-breakpoint
CREATE UNIQUE INDEX "unique_upper_artist_name" ON "artists" USING btree (upper(name) text_ops);--> statement-breakpoint
CREATE INDEX "idx_xp_rewards_created_at" ON "xp_rewards" USING btree ("created_at" timestamptz_ops);--> statement-breakpoint
CREATE INDEX "idx_xp_rewards_user_id" ON "xp_rewards" USING btree ("user_id" uuid_ops);--> statement-breakpoint
CREATE INDEX "idx_artist_members_member" ON "artist_members" USING btree ("member_artist_id" uuid_ops);--> statement-breakpoint
CREATE INDEX "idx_artist_members_parent" ON "artist_members" USING btree ("parent_artist_id" uuid_ops);--> statement-breakpoint
CREATE INDEX "idx_first_time_rankings_user" ON "first_time_rankings" USING btree ("user_id" uuid_ops);--> statement-breakpoint
CREATE INDEX "idx_activity_rewards_activity" ON "activity_rewards" USING btree ("activity_id" uuid_ops);--> statement-breakpoint
CREATE INDEX "idx_activity_rewards_reward" ON "activity_rewards" USING btree ("reward_id" uuid_ops);--> statement-breakpoint
CREATE VIEW "public"."event_sets_view" AS (SELECT s.id AS set_id, s.event_id, s.tier, s.display_name, s.set_note, a.id AS artist_id, a.name AS artist_name, a.type FROM event_sets s JOIN event_set_artists esa ON esa.set_id = s.id JOIN artists a ON a.id = esa.artist_id);--> statement-breakpoint
CREATE VIEW "public"."artist_contributions" AS (SELECT a.id AS artist_id, a.name AS artist_name, ua.user_id, u.raw_user_meta_data ->> 'full_name'::text AS contributor_name, ua.activity_type, count(*) AS contribution_count FROM artists a JOIN user_activities ua ON ua.artist_id = a.id JOIN auth.users u ON ua.user_id = u.id GROUP BY a.id, a.name, ua.user_id, (u.raw_user_meta_data ->> 'full_name'::text), ua.activity_type);--> statement-breakpoint
CREATE VIEW "public"."user_total_xp" AS (SELECT xp_rewards.user_id, COALESCE(sum(xp_rewards.total_xp_earned), 0::numeric)::bigint AS total_xp FROM xp_rewards GROUP BY xp_rewards.user_id);--> statement-breakpoint
CREATE VIEW "public"."artist_placements_with_names" AS (SELECT ap.id, ap.user_id, ap.artist_id, a.name AS artist_name, ap.tier, ap.updated_at FROM artist_placements ap JOIN artists a ON ap.artist_id = a.id);--> statement-breakpoint
CREATE POLICY "Admins can delete" ON "features" AS PERMISSIVE FOR DELETE TO public USING (has_role('admin'::text));--> statement-breakpoint
CREATE POLICY "Admins can insert" ON "features" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Admins can read" ON "features" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Admins can update" ON "features" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Authenticated users can read features" ON "features" AS PERMISSIVE FOR SELECT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Admins can delete" ON "artist_placements" AS PERMISSIVE FOR DELETE TO public USING (has_role('admin'::text));--> statement-breakpoint
CREATE POLICY "Admins can insert" ON "artist_placements" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Admins can read" ON "artist_placements" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Admins can update" ON "artist_placements" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Allow user to insert their own placements" ON "artist_placements" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Allow user to update their own placements" ON "artist_placements" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Allow user to view their own placements" ON "artist_placements" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Users can delete their own placements" ON "artist_placements" AS PERMISSIVE FOR DELETE TO "authenticated";--> statement-breakpoint
CREATE POLICY "Admins can delete" ON "event_sets" AS PERMISSIVE FOR DELETE TO public USING (has_role('admin'::text));--> statement-breakpoint
CREATE POLICY "Admins can insert" ON "event_sets" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Admins can read" ON "event_sets" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Admins can update" ON "event_sets" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "All users can read lineups" ON "event_sets" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Public can delete event lineups" ON "event_sets" AS PERMISSIVE FOR DELETE TO public;--> statement-breakpoint
CREATE POLICY "Public can insert event lineups" ON "event_sets" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Public can read all event lineups" ON "event_sets" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Public can update event lineups" ON "event_sets" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Admins can delete" ON "feature_votes" AS PERMISSIVE FOR DELETE TO public USING (has_role('admin'::text));--> statement-breakpoint
CREATE POLICY "Admins can insert" ON "feature_votes" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Admins can read" ON "feature_votes" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Admins can update" ON "feature_votes" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Authenticated users can insert their own votes" ON "feature_votes" AS PERMISSIVE FOR INSERT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Authenticated users can read feature votes" ON "feature_votes" AS PERMISSIVE FOR SELECT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Admins can delete" ON "events" AS PERMISSIVE FOR DELETE TO public USING (has_role('admin'::text));--> statement-breakpoint
CREATE POLICY "Admins can insert" ON "events" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Admins can read" ON "events" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Admins can update" ON "events" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Anyone can read published events" ON "events" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Public can delete events" ON "events" AS PERMISSIVE FOR DELETE TO public;--> statement-breakpoint
CREATE POLICY "Public can insert events" ON "events" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Public can read all events" ON "events" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Public can update events" ON "events" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Admins can delete" ON "artist_placement_history" AS PERMISSIVE FOR DELETE TO public USING (has_role('admin'::text));--> statement-breakpoint
CREATE POLICY "Admins can insert" ON "artist_placement_history" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Admins can read" ON "artist_placement_history" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Admins can update" ON "artist_placement_history" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Allow user to insert their own placement history" ON "artist_placement_history" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Allow user to update their own placement history" ON "artist_placement_history" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Anyone can get display names" ON "profiles" AS PERMISSIVE FOR SELECT TO public USING (true);--> statement-breakpoint
CREATE POLICY "Public profiles are viewable by everyone." ON "profiles" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Users can update own profile." ON "profiles" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "Activities are viewable by all users" ON "user_activities" AS PERMISSIVE FOR SELECT TO "authenticated" USING (true);--> statement-breakpoint
CREATE POLICY "Activities can only be inserted by the system" ON "user_activities" AS PERMISSIVE FOR INSERT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Admins can view all activities" ON "user_activities" AS PERMISSIVE FOR SELECT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Users can insert their own activities" ON "user_activities" AS PERMISSIVE FOR INSERT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Users can view their own activities" ON "user_activities" AS PERMISSIVE FOR SELECT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Admins can delete" ON "artists" AS PERMISSIVE FOR DELETE TO public USING (has_role('admin'::text));--> statement-breakpoint
CREATE POLICY "Admins can insert" ON "artists" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Admins can read" ON "artists" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Admins can update" ON "artists" AS PERMISSIVE FOR UPDATE TO public;--> statement-breakpoint
CREATE POLICY "All users can read artists" ON "artists" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Allow authenticated artist creation" ON "artists" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "Enable read access for all users" ON "artists" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Users can insert their own levels" ON "user_levels" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK ((auth.uid() = user_id));--> statement-breakpoint
CREATE POLICY "Users can update their own levels" ON "user_levels" AS PERMISSIVE FOR UPDATE TO "authenticated";--> statement-breakpoint
CREATE POLICY "Users can view their own levels" ON "user_levels" AS PERMISSIVE FOR SELECT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Users can insert their own rewards" ON "xp_rewards" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK ((auth.uid() = user_id));--> statement-breakpoint
CREATE POLICY "Users can view their own rewards" ON "xp_rewards" AS PERMISSIVE FOR SELECT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Enable delete for authenticated users only" ON "artist_members" AS PERMISSIVE FOR DELETE TO "authenticated" USING (true);--> statement-breakpoint
CREATE POLICY "Enable insert for authenticated users only" ON "artist_members" AS PERMISSIVE FOR INSERT TO "authenticated";--> statement-breakpoint
CREATE POLICY "Enable read access for all users" ON "artist_members" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "Enable update for authenticated users only" ON "artist_members" AS PERMISSIVE FOR UPDATE TO "authenticated";--> statement-breakpoint
CREATE POLICY "All users can delete lineup artists" ON "event_set_artists" AS PERMISSIVE FOR DELETE TO public USING (true);--> statement-breakpoint
CREATE POLICY "All users can insert lineup artists" ON "event_set_artists" AS PERMISSIVE FOR INSERT TO public;--> statement-breakpoint
CREATE POLICY "All users can read lineup artists" ON "event_set_artists" AS PERMISSIVE FOR SELECT TO public;--> statement-breakpoint
CREATE POLICY "All users can update lineup artists" ON "event_set_artists" AS PERMISSIVE FOR UPDATE TO public;
*/