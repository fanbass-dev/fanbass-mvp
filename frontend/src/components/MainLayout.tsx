import ArtistCanvas from './ArtistCanvas'
import { SearchBar } from './SearchBar'
import { ArtistRankingForm } from './ArtistRankingForm'
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
  updateTier: (id: string, tier: Tier) => void
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
}: Props) {
  return (
    <div style={{ display: 'flex', flex: 1, minHeight: 0 }}>
      <div
        style={{
          width: '300px',
          padding: '1rem',
          overflowY: 'auto',
          background: '#fafafa',
          position: 'relative',
          zIndex: 2,
        }}
      >
        <SearchBar
          searchTerm={searchTerm}
          searchResults={searchResults}
          searching={searching}
          onChange={onSearchChange}
          onAdd={onAddToQueue}
          queue={queue}
        />
      </div>
      <div
        style={{
          flex: 1,
          overflow: 'auto',
          position: 'relative',
          zIndex: 0,
          padding: '1rem',
        }}
      >
        {useFormUI ? (
          <ArtistRankingForm
            queue={queue}
            rankings={rankings}
            updateTier={updateTier}
          />
        ) : (
          <ArtistCanvas artists={queue} />
        )}
      </div>
    </div>
  )
}
