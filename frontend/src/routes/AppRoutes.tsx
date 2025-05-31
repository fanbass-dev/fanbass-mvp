import { Routes, Route } from 'react-router-dom'
import { MainLayout } from '../components/MainLayout'
import { ArtistPage } from '../features/artists/ArtistPage'
import FeatureVotingPage from '../features/featureVoting/FeatureVotingPage'
import { EventPage } from '../features/events/EventPage'
import { EventListPage } from '../features/events/EventListPage'
import type { Artist } from '../types/types'
import type { Tier } from '../constants/tiers'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onSearchChange: (term: string) => void
  onAddToQueue: (artist: Artist) => void
  queue: Artist[]
  useFormUI: boolean
  rankings: Record<string, Tier>
  updateTier: (artistId: string, newTier: Tier) => void
  removeArtist: (artistId: string) => void
  currentUser: any
}

export function AppRoutes({
  searchTerm,
  searchResults,
  searching,
  onSearchChange,
  onAddToQueue,
  queue,
  useFormUI,
  rankings,
  updateTier,
  removeArtist,
  currentUser,
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
            queue={queue}
            useFormUI={useFormUI}
            rankings={rankings}
            updateTier={updateTier}
            removeArtist={removeArtist}
          />
        }
      />
      <Route path="/artist/:id" element={<ArtistPage currentUser={currentUser} />} />
      <Route path="/feature-voting" element={<FeatureVotingPage />} />
      <Route path="/event/:eventKey" element={<EventPage />} />
      <Route path="/events" element={<EventListPage />} />
    </Routes>
  )
}
