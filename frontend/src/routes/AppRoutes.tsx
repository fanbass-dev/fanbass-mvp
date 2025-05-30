import { Routes, Route } from 'react-router-dom'
import { MainLayout } from '../components/MainLayout'
import { ArtistPage } from '../components/ArtistPage'
import FeatureVotingPage from '../components/FeatureVotingPage'
import { EventForm } from '../components/EventForm'
import { EventPage } from '../components/EventPage'
import { EventListPage } from '../components/EventListPage'
import type { Artist, Tier } from '../types'

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
                    />
                }
            />
            <Route path="/artist/:id" element={<ArtistPage currentUser={currentUser} />} />
            <Route path="/feature-voting" element={<FeatureVotingPage />} />
            <Route path="/event/:eventKey" element={<EventPage />} />
            <Route path="/event/new" element={<EventForm />} /> {/* ✅ Added new route */}
            <Route path="/events" element={<EventListPage />} />
        </Routes>
    )
}
