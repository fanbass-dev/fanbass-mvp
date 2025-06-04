import { Routes, Route } from 'react-router-dom'
import { MainLayout } from '../components/MainLayout'
import { ArtistPage } from '../features/artists/ArtistPage'
import FeatureVotingPage from '../features/featureVoting/FeatureVotingPage'
import { EventPage } from '../features/events/EventPage'
import { EventListPage } from '../features/events/EventListPage'
import ArtistRankingsAdmin from '../features/admin/ArtistRankingsAdmin'
import type { Artist } from '../types/types'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onSearchChange: (term: string) => void
  onAddToQueue: (artist: Artist) => void
  useFormUI: boolean
  currentUser: any
  myArtists: Artist[]
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
          />
        }
      />
      <Route path="/artist/:id" element={<ArtistPage currentUser={currentUser} />} />
      <Route path="/feature-voting" element={<FeatureVotingPage />} />
      <Route path="/event/:eventKey" element={<EventPage />} />
      <Route path="/events" element={<EventListPage />} />
      <Route path="/admin/artist-rankings" element={<ArtistRankingsAdmin />} />
    </Routes>
  )
}
