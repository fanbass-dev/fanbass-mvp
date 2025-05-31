import type { Tier } from '../constants/tiers'
import { ArtistRankingForm } from '../features/artists/ArtistRankingForm'
import ArtistCanvas from '../features/artists/pixiCanvas/ArtistCanvas'
import type { Artist } from '../types/types'
import './MainLayout.css'
import { SearchBar } from './SearchBar'
import { useArtistRankings } from '../features/artists/useArtistRankings'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onSearchChange: (term: string) => void
  onAddToQueue: (artist: Artist) => void
  useFormUI: boolean
}

export function MainLayout({
  searchTerm,
  searchResults,
  searching,
  onSearchChange,
  onAddToQueue,
  useFormUI,
}: Props) {
  const {
    myArtists: queue,
    rankings,
    updateTier,
    removeArtistFromQueue,
  } = useArtistRankings()

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
            removeArtist={removeArtistFromQueue}
          />
        ) : (
          <ArtistCanvas artists={queue} />
        )}
      </div>
    </div>
  )
}
