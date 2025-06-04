# Event Lineups

## Overview
Event Lineups is a feature that transforms traditional festival schedules into personalized experiences. It combines user rankings with event data to create dynamic, preference-aware lineup displays and helps fans make informed decisions about their event experience.

## User Stories

### Fan Perspective
- As a fan, I want to see event lineups organized by my personal rankings
- As a fan, I want to discover conflicts between must-see artists
- As a fan, I want to plan my event schedule efficiently
- As a fan, I want to explore new artists in the lineup

### Industry Perspective
- As a promoter, I want to understand how fans perceive the lineup
- As a promoter, I want to optimize set times based on fan preferences
- As a venue, I want to manage stage capacities effectively

## Implementation

### Data Model

```typescript
type EventSet = {
  id: string
  event_id: string
  artist_id: string
  start_time?: string
  end_time?: string
  stage?: string
  tier?: string
  display_name?: string
  notes?: string
}

type Event = {
  id: string
  name: string
  slug: string
  start_date: string
  end_date: string
  timezone: string
  venue?: string
  location?: string
}

type Stage = {
  id: string
  event_id: string
  name: string
  capacity?: number
}
```

### Key Components

1. **EventLineupView**
   - Main lineup display interface
   - Personalized artist sorting
   - Time conflict visualization
   - Stage-based organization

2. **ScheduleBuilder**
   - Interactive schedule creation
   - Conflict resolution
   - Time slot management
   - Stage capacity tracking

3. **ArtistSetCard**
   - Individual set display
   - Personal ranking integration
   - Set time information
   - Stage details

### Custom Hooks

1. **useEventLineup**
   - Manages event lineup data
   - Provides lineup operations

```typescript
const useEventLineup = (eventId: string) => {
  // State for lineup and schedule
  const [sets, setSets] = useState<EventSet[]>([])
  const [stages, setStages] = useState<Stage[]>([])
  const [conflicts, setConflicts] = useState<Conflict[]>([])

  // Operations
  const updateSetTime = async (setId: string, startTime: string, endTime: string) => {...}
  const updateStage = async (setId: string, stageId: string) => {...}
  const detectConflicts = () => {...}

  return {
    sets,
    stages,
    conflicts,
    updateSetTime,
    updateStage,
    detectConflicts
  }
}
```

### Database Tables

1. **events**
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
   ```

2. **event_sets**
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
   ```

3. **stages**
   ```sql
   create table stages (
     id uuid primary key,
     event_id uuid references events not null,
     name text not null,
     capacity integer,
     created_at timestamp with time zone default timezone('utc'::text, now())
   );
   ```

### Schedule Optimization

1. **Conflict Resolution**
   - Detect time conflicts
   - Suggest alternative times
   - Consider stage capacities

2. **Capacity Management**
   - Track stage capacities
   - Predict crowd movements
   - Optimize stage assignments

### Performance Optimizations

1. **Data Loading**
   - Lazy load set details
   - Cache lineup data

2. **UI Performance**
   - Virtual scrolling for large lineups
   - Efficient time slot rendering
   - Optimized conflict checking

## Future Enhancements

1. **Smart Scheduling**
   - AI-powered schedule optimization
   - Crowd flow prediction
   - Dynamic stage assignments

2. **Social Features**
   - Group schedule coordination
   - Shared viewing plans
   - Meet-up suggestions

3. **Real-time Updates**
   - Live schedule changes
   - Instant conflict notifications
   - Dynamic capacity updates 