# FanBass Architecture Guide

## Technical Stack

### Frontend
- **Framework**: React with TypeScript
- **Routing**: React Router v7
- **Styling**: Tailwind CSS
- **UI Components**: Custom components with Lucide icons
- **State Management**: React Context + Hooks pattern
- **Data Visualization**: PixiJS for canvas-based visualizations

### Backend
- **Platform**: Supabase
- **Database**: PostgreSQL
- **Authentication**: Supabase Auth with Google OAuth
- **Storage**: Supabase Storage (when needed)

## Data Flow Architecture

### Authentication Flow
1. User signs in via Google OAuth through Supabase Auth
2. Session is managed by `useAuth` hook and `UserContext`
3. User roles and permissions are fetched and cached in `UserContext`
4. Protected routes and features check permissions via `useUserContext`

### State Management
The application uses a hybrid state management approach:

1. **Global State**
   - `UserContext`: User authentication and roles
   - React Router: Navigation and URL state

2. **Feature State**
   - Custom hooks for feature-specific state
   - Local component state for UI elements

3. **Data Fetching Pattern**
   ```typescript
   const CustomHook = () => {
     const [data, setData] = useState()
     const [loading, setLoading] = useState(true)
     
     useEffect(() => {
       // Initial data fetch
       const fetchData = async () => {...}
       fetchData()
     }, [])
     
     return { data, loading }
   }
   ```

## Database Schema

### Core Tables
1. **artists**
   - Primary data about music artists
   - Unique constraint on artist name (case-insensitive)
   - Fields: id, name, created_at

2. **events**
   - Music events/festivals
   - Configurable tier system
   - Slug-based routing
   - Fields: id, name, date, description, created_at

3. **artist_placements**
   - User preferences for artists
   - Tier-based ranking system
   - Tracks updated_at via trigger
   - Fields: id, user_id, artist_id, tier, created_at, updated_at

4. **artist_placement_history**
   - Historical record of placement changes
   - Tracks all modifications to artist placements
   - Fields: id, placement_id, previous_tier, new_tier, changed_at

5. **b2b_sets**
   - Back-to-back performance configurations
   - Unique fingerprint based on sorted artist IDs
   - Automated fingerprint generation via triggers
   - Fields: id, fingerprint, created_at

6. **event_sets**
   - Event lineup entries
   - Support for B2B performances
   - Custom display names and notes
   - Fields: id, event_id, b2b_set_id, display_name, notes, created_at

7. **event_set_artists**
   - Many-to-many relationship between event sets and artists
   - Enables flexible artist combinations in sets
   - Fields: id, event_set_id, artist_id

8. **features**
   - Feature suggestions and requests
   - Public tracking of platform features
   - Fields: id, title, description, status, created_at

9. **feature_votes**
   - User voting on feature requests
   - One vote per user per feature
   - Fields: id, feature_id, user_id, created_at

10. **roles**
    - User role assignments
    - Supports multiple roles per user
    - Types: admin, fan, artist, promoter
    - Fields: id, user_id, role, created_at

### Views
1. **event_sets_view**
   - Denormalized view of event lineups
   - Combines artist and set information
   - Optimized for frontend queries
   - Includes event details, set information, and artist names

### Database Functions

1. **Artist Management**
   - `generate_b2b_fingerprint(artist_ids uuid[])`: Generates a unique fingerprint for B2B sets
   - `sorted_artist_fingerprint(text[])`: Helper function for consistent fingerprint generation

2. **Feature Management**
   - `get_feature_votes(uid uuid)`: Returns feature votes with user-specific voting status

3. **User Management**
   - `handle_new_user_role()`: Automatically assigns default role to new users
   - `has_role(role_name text)`: Checks if the current user has a specific role

4. **Utility Functions**
   - `update_updated_at_column()`: Updates timestamp columns automatically
   - `set_b2b_fingerprint()`: Manages B2B set fingerprint updates

### Database Triggers

1. **User Management**
   - `on_auth_user_created`: Assigns default role to new users
   - Triggered after INSERT on auth.users

2. **B2B Set Management**
   - `trigger_set_b2b_fingerprint`: Maintains B2B set fingerprints
   - Triggered before INSERT or UPDATE on b2b_sets

3. **Timestamp Management**
   - `set_updated_at`: Updates timestamp on artist_placements
   - Triggered before UPDATE on artist_placements

## Security Model

### Access Levels

1. **Public Access**
   - View published events
   - View artist information
   - View event lineups and B2B sets
   - Access to basic platform features

2. **Authenticated Users**
   - All public access capabilities
   - Create and manage personal artist rankings
   - Vote on feature requests
   - Submit new artist entries
   - Track personal placement history

3. **Admin Users**
   - Full platform management capabilities
   - Content moderation
   - User management
   - System configuration

### Data Access Patterns

1. **Artist Management**
   - Public read access to artist information
   - Authenticated users can submit new artists
   - Historical tracking of artist data changes

2. **Event Management**
   - Public access to published events
   - Tiered visibility based on event status
   - Lineup management with B2B support

3. **User Preferences**
   - User-specific artist rankings
   - Personal placement history
   - Individual feature voting

4. **Feature Management**
   - Public feature visibility
   - Vote tracking per user
   - Status tracking and updates

### Data Protection

The application implements comprehensive security measures using Supabase's Row Level Security (RLS) features. Access control is implemented at the database level, ensuring data protection regardless of access point. For detailed security implementation, please refer to internal documentation.

## Frontend Architecture

### Directory Structure
```
frontend/src/
├── components/    # Reusable UI components
├── constants/     # Application constants
├── context/      # React contexts
├── features/     # Feature modules
├── hooks/        # Custom React hooks
├── routes/       # Route definitions
├── services/     # API services
├── types/        # TypeScript types
└── utils/        # Utility functions
```

### Feature Organization
Each feature module contains:
1. Main component(s)
2. Custom hooks
3. Type definitions
4. Utility functions
5. Sub-components

### Component Patterns
1. **Smart/Container Components**
   - Handle data fetching
   - Manage state
   - Coordinate child components

2. **Presentation Components**
   - Pure rendering logic
   - Prop-based configuration
   - Reusable design

3. **Hook-based Features**
   - Encapsulated logic
   - Reusable state management
   - Data synchronization

## Development Workflow

### State Updates
1. Optimistic UI updates
2. Error handling and rollback
3. Batch operations

### Data Fetching
1. Initial load with loading states
2. Cached data management
3. Error state handling

### Error Handling
1. User-friendly error messages
2. Automatic retry logic
3. Fallback UI states

## Performance Considerations

### Optimization Techniques
1. Memoization of expensive calculations
2. Lazy loading of routes
3. Debounced search inputs
4. Virtual scrolling for large lists

### Data Management
1. Local state caching
2. Optimistic updates
3. Batch operations
4. Connection management

## Future Considerations

### Scalability
1. Code splitting
2. Performance monitoring
3. Caching strategies
4. Load balancing

### Maintainability
1. Consistent patterns
2. Documentation
3. Type safety
4. Testing strategy

### Real-time Features
1. Live updates for rankings
2. Real-time event changes
3. Instant feature voting
4. Collaborative editing 