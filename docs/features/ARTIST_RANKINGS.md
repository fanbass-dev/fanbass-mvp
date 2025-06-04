# Artist Rankings

## Overview
Artist Rankings is a core feature that allows users to express their musical preferences through a structured tier system. This feature transforms subjective music taste into actionable signal for the industry while helping fans organize their music experiences.

## User Stories

### Fan Perspective
- As a fan, I want to rank artists to personalize my festival experience
- As a fan, I want to track my music preferences over time
- As a fan, I want to discover new artists based on my rankings
- As a fan, I want to share my musical taste with friends

### Industry Perspective
- As a promoter, I want to understand fan preferences for booking decisions
- As an artist, I want to see my ranking distribution across different audiences
- As a venue, I want to identify which artists resonate with local crowds

## Implementation

### Data Model

```typescript
type Tier =
  | 'must_see'
  | 'worth_the_effort'
  | 'nice_to_catch'
  | 'depends_on_context'
  | 'not_for_me'
  | 'unranked'

type Artist = {
  id: string
  name: string
  is_b2b?: boolean
  original_ids?: string[]
}

type ArtistPlacement = {
  user_id: string
  artist_id: string
  tier: Tier
  updated_at: string
}
```

### Key Components

1. **ArtistRankingForm**
   - Main interface for ranking artists
   - Drag-and-drop tier assignment

2. **ArtistCanvas**
   - Visual representation of rankings
   - Interactive artist exploration
   - PixiJS-powered visualization

3. **SearchBar**
   - Artist search functionality
   - B2B set creation
   - Queue management

### Custom Hooks

1. **useArtistRankings**
   - Manages user's artist rankings
   - Provides ranking operations

```typescript
const useArtistRankings = () => {
  // State for artists and their rankings
  const [myArtists, setMyArtists] = useState<Artist[]>([])
  const [rankings, setRankings] = useState<Record<string, Tier>>({})

  // Operations
  const addArtistToQueue = async (artist: Artist) => {...}
  const removeArtistFromQueue = async (id: string) => {...}
  const updateTier = async (id: string, tier: Tier) => {...}

  return {
    myArtists,
    rankings,
    addArtistToQueue,
    removeArtistFromQueue,
    updateTier
  }
}
```

2. **useArtistSearch**
   - Provides artist search functionality
   - Handles B2B set creation
   - Manages search results

### Database Tables

1. **artists**
   ```sql
   create table artists (
     id uuid primary key,
     name text not null,
     created_at timestamp with time zone default timezone('utc'::text, now())
   );
   ```

2. **artist_placements**
   ```sql
   create table artist_placements (
     user_id uuid references auth.users,
     artist_id uuid references artists,
     tier text not null,
     updated_at timestamp with time zone default timezone('utc'::text, now()),
     primary key (user_id, artist_id)
   );
   ```

3. **b2b_sets**
   ```sql
   create table b2b_sets (
     id uuid primary key,
     name text not null,
     artist_ids uuid[] not null,
     created_at timestamp with time zone default timezone('utc'::text, now())
   );
   ```

### Error Handling

1. **Network Issues**
   - Retry failed ranking updates
   - Cache pending changes
   - Show sync status to user

2. **Data Validation**
   - Validate tier values
   - Check for duplicate rankings
   - Handle missing artists

### Performance Optimizations

1. **Data Loading**
   - Initial batch load of rankings
   - Cached artist data

2. **UI Performance**
   - Virtualized lists for large datasets
   - Debounced search
   - Memoized ranking calculations

## Future Enhancements

1. **Analytics**
   - Ranking trends over time
   - Genre affinity analysis
   - Geographic preference patterns

2. **Social Features**
   - Share rankings with friends
   - Compare rankings
   - Collaborative playlists

3. **Real-time Updates**
   - Live ranking changes
   - Instant tier updates
   - Collaborative ranking sessions 