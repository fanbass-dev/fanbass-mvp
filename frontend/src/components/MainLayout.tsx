import type { Tier } from '../constants/tiers'
import { ArtistRankingForm } from '../features/artists/ArtistRankingForm'
import ArtistCanvas from '../features/artists/pixiCanvas/ArtistCanvas'
import type { Artist } from '../types/types'
import './MainLayout.css'
import { SearchBar } from './SearchBar'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onSearchChange: (term: string) => void
  onAddToQueue: (artist: Artist) => void
  queue: Artist[]
  useFormUI: boolean
  rankings: Record<string, Tier>
  updateTier: (id: string, tier: Tier) => void
  removeArtist: (id: string) => void
}

export function MainLayout({
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
}: Props) {
  return (
    <div className="layout">
      <div className="sidebar">
        <SearchBar
          searchTerm={searchTerm}
          searchResults={searchResults}
          searching={searching}
          onChange={onSearchChange}
          onAdd={onAddToQueue}
          queue={queue}
        />
      </div>
      <div className="mainContent">
        {useFormUI ? (
          <ArtistRankingForm
            queue={queue}
            rankings={rankings}
            updateTier={updateTier}
            removeArtist={removeArtist}
          />
        ) : (
          <ArtistCanvas artists={queue} />
        )}
      </div>
    </div>
  )
}
