import { Routes, Route } from 'react-router-dom'
import { MainLayout } from '../components/MainLayout'
import { ArtistPage } from '../features/artists/ArtistPage'
import FeatureVotingPage from '../features/featureVoting/FeatureVotingPage'
import { EventPage } from '../features/events/EventPage'
import { EventListPage } from '../features/events/EventListPage'
import ArtistRankingsAdmin from '../features/admin/ArtistRankingsAdmin'
import { ProfileSettingsPage } from '../features/profile/ProfileSettingsPage'
import { UserStatsPage } from '../features/profile/UserStatsPage'
import type { Artist } from '../types/types'
import type { Tier } from '../constants/tiers'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onSearchChange: (term: string) => void
  onAddToQueue: (artist: Artist) => void
  useFormUI: boolean
  currentUser: any
  myArtists: Artist[]
  rankings: Record<string, Tier>
  updateTier: (id: string, tier: Tier) => void
  removeArtistFromQueue: (id: string) => void
}

export function AppRoutes({
  searchTerm,
  searchResults,
  searching,
  onSearchChange,
  onAddToQueue,
  useFormUI,
  currentUser,
  myArtists,
  rankings,
  updateTier,
  removeArtistFromQueue,
}: Props) {
  return (
    <Routes>
      <Route
        path="/"
        element={
          <MainLayout
            searchTerm={searchTerm}
            searchResults={searchResults}
            searching={searching}
            onSearchChange={onSearchChange}
            onAddToQueue={onAddToQueue}
            useFormUI={useFormUI}
            myArtists={myArtists}
            rankings={rankings}
            updateTier={updateTier}
            removeArtist={removeArtistFromQueue}
            currentUser={currentUser}
          />
        }
      />
      <Route path="/artist/:id" element={<ArtistPage currentUser={currentUser} />} />
      <Route path="/feature-voting" element={<FeatureVotingPage />} />
      <Route path="/event/:eventKey" element={<EventPage currentUser={currentUser} />} />
      <Route path="/events" element={<EventListPage />} />
      <Route path="/admin/artist-rankings" element={<ArtistRankingsAdmin />} />
      <Route path="/settings/profile" element={<ProfileSettingsPage />} />
      <Route path="/settings/stats" element={<UserStatsPage />} />
    </Routes>
  )
}
