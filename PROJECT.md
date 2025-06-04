# FanBass: A Feedback Resonator for Music Culture

FanBass makes it fun to live your music life with intention—plan shows, catalog memories, and share your perspective with friends. What you share doesn't disappear—it helps shape the future of the scene.

## Mission

FanBass gives fans the power to resonate—not just react. While fans already do the work of ranking artists, debating lineups, and planning set times, FanBass gives that energy a home—a platform built for the way people actually engage with music culture.

## Core Features

### Artist Rankings
Users can express their musical identity through a nuanced five-tier preference system:
- Must see
- Worth the effort
- Cool if convenient
- It depends
- Not for me

This structured feedback system helps fans plan their experience while providing actionable signal to the industry.

### Event Lineups
- Personalized festival and event lineups based on your preferences
- Support for both individual artists and B2B (back-to-back) sets
- Custom grouping and sorting options
- Set notes and custom display names for performances

### Community Engagement
- Share your musical identity with friends
- Provide structured feedback on events
- Vote on platform features and improvements
- Help shape how artists, promoters, and venues listen and improve

### Industry Tools
Administrative features enabling the industry to:
- Access real-time fan insights
- Make data-driven event planning decisions
- Discover overlooked artists and underserved markets
- Manage lineups and bulk operations

## Technical Implementation

### Stack
- Frontend: React with TypeScript
- Backend: Supabase
- Real-time updates for live data synchronization
- Modern UI with responsive design

### Directory Structure

```
frontend/src/
├── components/    # Reusable UI components
├── constants/     # Application constants and configurations
├── context/      # React context providers
├── features/     # Core feature implementations
│   ├── admin/    # Industry tools
│   ├── artists/  # Artist ranking system
│   ├── events/   # Event management
│   └── featureVoting/ # Community feature voting
├── hooks/        # Custom React hooks
├── routes/       # Application routing
├── services/     # Backend service integrations
├── types/        # TypeScript type definitions
└── utils/        # Utility functions
```

## Key Concepts

### Structured Feedback
The platform transforms subjective taste into actionable signal through:
- Tiered ranking system
- Event experience feedback
- Community-driven feature development

### Events
Music festivals and concerts are enhanced with:
- Personalized lineup views
- Customizable tier systems
- Fan-driven insights
- Location and scheduling tools

### B2B Sets
Support for back-to-back performances that:
- Capture collaborative artist moments
- Enable special ranking considerations
- Provide flexible display options

### Data Philosophy
- Feedback is the foundation of better culture
- Data should elevate, not extract
- Fans deserve to be heard, not harvested
- Goodwill should be rewarded, not squeezed

## Getting Started

[Development setup instructions to be added in Layer 5] 