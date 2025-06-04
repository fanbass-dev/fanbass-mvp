# Database Schema

## Overview
FanBass uses PostgreSQL via Supabase as its primary database. The schema is designed to support the core features of artist rankings, event management, and feature voting while maintaining data integrity and enabling efficient queries.

## Core Tables

### artists
Stores information about music artists, including both individual artists and B2B sets.

```sql
create table artists (
  id uuid primary key,
  name text not null,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Indexes
create index artists_name_idx on artists (name);
```

**Fields:**
- `id` - Unique identifier for the artist
- `name` - Artist's display name
- `created_at` - Timestamp of when the artist was added

### b2b_sets
Represents back-to-back performance combinations of multiple artists.

```sql
create table b2b_sets (
  id uuid primary key,
  name text not null,
  artist_ids uuid[] not null,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Indexes
create index b2b_sets_artist_ids_idx on b2b_sets using gin (artist_ids);
```

**Fields:**
- `id` - Unique identifier for the B2B set
- `name` - Display name for the B2B combination
- `artist_ids` - Array of artist IDs in the set
- `created_at` - Timestamp of when the set was created

### events
Stores music events and festivals.

```sql
create table events (
  id uuid primary key,
  name text not null,
  slug text unique not null,
  start_date timestamp with time zone not null,
  end_date timestamp with time zone not null,
  timezone text not null,
  venue text,
  location text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Indexes
create unique index events_slug_idx on events (slug);
create index events_dates_idx on events (start_date, end_date);
```

**Fields:**
- `id` - Unique identifier for the event
- `name` - Event name
- `slug` - URL-friendly unique identifier
- `start_date` - Event start date and time
- `end_date` - Event end date and time
- `timezone` - Event timezone
- `venue` - Optional venue name
- `location` - Optional location description
- `created_at` - Timestamp of when the event was created

### stages
Represents performance stages at events.

```sql
create table stages (
  id uuid primary key,
  event_id uuid references events not null,
  name text not null,
  capacity integer,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Indexes
create index stages_event_id_idx on stages (event_id);
```

**Fields:**
- `id` - Unique identifier for the stage
- `event_id` - Reference to the associated event
- `name` - Stage name
- `capacity` - Optional stage capacity
- `created_at` - Timestamp of when the stage was created

### event_sets
Represents artist performances at events.

```sql
create table event_sets (
  id uuid primary key,
  event_id uuid references events not null,
  artist_id uuid references artists not null,
  start_time timestamp with time zone,
  end_time timestamp with time zone,
  stage_id uuid references stages,
  tier text,
  display_name text,
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Indexes
create index event_sets_event_id_idx on event_sets (event_id);
create index event_sets_artist_id_idx on event_sets (artist_id);
create index event_sets_stage_id_idx on event_sets (stage_id);
create index event_sets_times_idx on event_sets (start_time, end_time);
```

**Fields:**
- `id` - Unique identifier for the set
- `event_id` - Reference to the associated event
- `artist_id` - Reference to the performing artist
- `start_time` - Optional set start time
- `end_time` - Optional set end time
- `stage_id` - Optional reference to the performance stage
- `tier` - Optional tier categorization
- `display_name` - Optional custom display name
- `notes` - Optional additional information
- `created_at` - Timestamp of when the set was created

### artist_placements
Stores user rankings for artists.

```sql
create table artist_placements (
  user_id uuid references auth.users,
  artist_id uuid references artists,
  tier text not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()),
  primary key (user_id, artist_id)
);

-- Indexes
create index artist_placements_user_id_idx on artist_placements (user_id);
create index artist_placements_artist_id_idx on artist_placements (artist_id);
```

**Fields:**
- `user_id` - Reference to the user
- `artist_id` - Reference to the ranked artist
- `tier` - User's ranking tier for the artist
- `updated_at` - Timestamp of last ranking update

### features
Stores feature suggestions and voting information.

```sql
create table features (
  id uuid primary key,
  title text not null,
  description text not null,
  status text not null,
  category text not null,
  created_by uuid references auth.users not null,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Indexes
create index features_status_idx on features (status);
create index features_category_idx on features (category);
create index features_created_by_idx on features (created_by);
```

**Fields:**
- `id` - Unique identifier for the feature
- `title` - Feature title
- `description` - Feature description
- `status` - Current status (proposed, under_review, planned, etc.)
- `category` - Feature category
- `created_by` - Reference to the user who proposed the feature
- `created_at` - Timestamp of when the feature was created
- `updated_at` - Timestamp of last feature update

### feature_votes
Stores user votes on feature suggestions.

```sql
create table feature_votes (
  user_id uuid references auth.users,
  feature_id uuid references features,
  vote_type text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  primary key (user_id, feature_id)
);

-- Indexes
create index feature_votes_feature_id_idx on feature_votes (feature_id);
```

**Fields:**
- `user_id` - Reference to the voting user
- `feature_id` - Reference to the voted feature
- `vote_type` - Type of vote (upvote/downvote)
- `created_at` - Timestamp of when the vote was cast

### feature_comments
Stores user comments on feature suggestions.

```sql
create table feature_comments (
  id uuid primary key,
  feature_id uuid references features not null,
  user_id uuid references auth.users not null,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Indexes
create index feature_comments_feature_id_idx on feature_comments (feature_id);
create index feature_comments_user_id_idx on feature_comments (user_id);
```

**Fields:**
- `id` - Unique identifier for the comment
- `feature_id` - Reference to the commented feature
- `user_id` - Reference to the commenting user
- `content` - Comment text
- `created_at` - Timestamp of when the comment was created
- `updated_at` - Timestamp of last comment update

## Views

### artist_placements_with_names
A view that combines artist placement information with artist names.

```sql
SELECT 
    ap.id,
    ap.user_id,
    ap.artist_id,
    a.name AS artist_name,
    ap.tier,
    ap.updated_at
FROM artist_placements ap
JOIN artists a ON ap.artist_id = a.id
```

### event_sets_view
A view that shows event sets with associated artist information.

```sql
SELECT 
    s.id AS set_id,
    s.event_id,
    s.tier,
    s.display_name,
    s.set_note,
    a.id AS artist_id,
    a.name AS artist_name
FROM event_sets s
JOIN event_set_artists esa ON esa.set_id = s.id
JOIN artists a ON a.id = esa.artist_id
```

## Triggers

### artist_placements
- `set_updated_at`: BEFORE UPDATE trigger that updates the `updated_at` timestamp

### b2b_sets
- `trigger_set_b2b_fingerprint`: BEFORE INSERT/UPDATE trigger that sets the fingerprint
- `trigger_set_fingerprint`: BEFORE INSERT/UPDATE trigger that also handles fingerprint generation

## Functions

### Role Management
- `has_role(role_name text) returns boolean`
  - Checks if the authenticated user has a specific role
  - Used in RLS policies

### Feature Management
- `get_feature_votes() returns record`
  - Returns feature voting information including:
    - Feature ID, title, description, status
    - Vote count
    - Whether current user voted
    - Creation timestamp

### B2B Set Management
- `sorted_artist_fingerprint(text[]) returns text`
  - Takes an array of artist IDs and returns them as a sorted, comma-separated string
- `generate_b2b_fingerprint(text[]) returns text`
  - Generates a fingerprint for b2b sets based on artist IDs
- `set_b2b_fingerprint() returns trigger`
  - Trigger function that sets the fingerprint for b2b sets

### User Management
- `handle_new_user_role() returns trigger`
  - Automatically assigns the 'fan' role to new users
  - Runs as a trigger on user creation

### Utility Functions
- `update_updated_at_column() returns trigger`
  - Updates the `updated_at` timestamp column
  - Used by various tables that track modification time 