# Common Types

## Overview
This document describes the common TypeScript types used throughout the FanBass application. These types are shared across different features and components.

## Core Types

### Artist Types
```typescript
type Artist = {
  id: string
  name: string
  is_b2b?: boolean
  original_ids?: string[]
}

type B2BSet = {
  id: string
  name: string
  artist_ids: string[]
  created_at: string
}

type Tier =
  | 'must_see'
  | 'worth_the_effort'
  | 'nice_to_catch'
  | 'depends_on_context'
  | 'not_for_me'
  | 'unranked'

type ArtistPlacement = {
  user_id: string
  artist_id: string
  tier: Tier
  updated_at: string
}
```

### Event Types
```typescript
type Event = {
  id: string
  name: string
  slug: string
  start_date: string
  end_date: string
  timezone: string
  venue?: string
  location?: string
  created_at: string
}

type Stage = {
  id: string
  event_id: string
  name: string
  capacity?: number
  created_at: string
}

type EventSet = {
  id: string
  event_id: string
  artist_id: string
  start_time?: string
  end_time?: string
  stage_id?: string
  tier?: string
  display_name?: string
  notes?: string
  created_at: string
}

type Conflict = {
  set1: EventSet
  set2: EventSet
  overlap_duration: number
}
```

### Feature Types
```typescript
type FeatureStatus =
  | 'proposed'
  | 'under_review'
  | 'planned'
  | 'in_progress'
  | 'completed'
  | 'declined'

type Feature = {
  id: string
  title: string
  description: string
  status: FeatureStatus
  category: string
  created_by: string
  created_at: string
  updated_at: string
}

type VoteType = 'upvote' | 'downvote'

type FeatureVote = {
  user_id: string
  feature_id: string
  vote_type: VoteType
  created_at: string
}

type FeatureComment = {
  id: string
  feature_id: string
  user_id: string
  content: string
  created_at: string
  updated_at: string
}
```

### User Types
```typescript
type UserRole = 'admin' | 'fan' | 'artist' | 'promoter'

type User = {
  id: string
  email: string
  roles: UserRole[]
  created_at: string
  updated_at: string
}
```

### Common Utility Types
```typescript
type Timestamp = string // ISO 8601 format

type PaginationParams = {
  page: number
  per_page: number
}

type SortDirection = 'asc' | 'desc'

type SortParams = {
  field: string
  direction: SortDirection
}

type ApiResponse<T> = {
  data?: T
  error?: {
    message: string
    code: string
  }
}

type LoadingState = 'idle' | 'loading' | 'success' | 'error'
```

## Type Guards

### Artist Type Guards
```typescript
const isB2BArtist = (artist: Artist): boolean => {
  return artist.is_b2b === true && Array.isArray(artist.original_ids)
}

const isSoloArtist = (artist: Artist): boolean => {
  return !isB2BArtist(artist)
}
```

### Feature Type Guards
```typescript
const isCompletedFeature = (feature: Feature): boolean => {
  return feature.status === 'completed'
}

const isPendingFeature = (feature: Feature): boolean => {
  return ['proposed', 'under_review', 'planned', 'in_progress'].includes(feature.status)
}
```

### User Type Guards
```typescript
const isAdmin = (user: User): boolean => {
  return user.roles.includes('admin')
}

const isPromoter = (user: User): boolean => {
  return user.roles.includes('promoter')
}
```

## Type Utilities

### Time Utilities
```typescript
const parseTimestamp = (timestamp: Timestamp): Date => {
  return new Date(timestamp)
}

const formatTimestamp = (date: Date): Timestamp => {
  return date.toISOString()
}
```

### Sorting Utilities
```typescript
const createSortParams = (field: string, direction: SortDirection): SortParams => {
  return { field, direction }
}
```

## Database Views

### ArtistPlacementWithName
```typescript
interface ArtistPlacementWithName {
  id: string;
  user_id: string;
  artist_id: string;
  artist_name: string;
  tier: number;
  updated_at: string;
}
```

### EventSetView
```typescript
interface EventSetView {
  set_id: string;
  event_id: string;
  tier: number;
  display_name: string;
  set_note: string | null;
  artist_id: string;
  artist_name: string;
}
```

## Feature Management

### FeatureVote
```typescript
interface FeatureVote {
  id: string;
  title: string;
  description: string;
  status: string;
  vote_count: number;
  user_voted: boolean;
  created_at: string;
}
```

## User Management

### UserRole
```typescript
interface UserRole {
  user_id: string;
  role: 'fan' | string; // 'fan' is the default role
}
```

## B2B Sets

### B2BSet
```typescript
interface B2BSet {
  id: string;
  artist_ids: string[];
  fingerprint: string; // Generated from sorted artist IDs
}
```

## Common Properties

### TimestampColumns
```typescript
interface TimestampColumns {
  created_at: string;
  updated_at: string;
}
```

### EventSet
```typescript
interface EventSet {
  id: string;
  event_id: string;
  tier: number;
  display_name: string;
  set_note?: string;
}
```

### ArtistPlacement
```typescript
interface ArtistPlacement extends TimestampColumns {
  id: string;
  user_id: string;
  artist_id: string;
  tier: number;
} 