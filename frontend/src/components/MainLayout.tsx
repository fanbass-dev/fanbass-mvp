import ArtistCanvas from './ArtistCanvas'
import { SearchBar } from './SearchBar'
import { ArtistRankingForm } from './ArtistRankingForm' // ✅ Add this
import type { Artist } from '../types'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onSearchChange: (term: string) => void
  onAddToQueue: (artist: Artist) => void
  queue: Artist[]
  useFormUI: boolean
}

export function MainLayout({
  searchTerm,
  searchResults,
  searching,
  onSearchChange,
  onAddToQueue,
  queue,
  useFormUI, // ✅ You forgot to destructure this earlier
}: Props) {
  return (
    <div style={{ display: 'flex', flex: 1, minHeight: 0 }}>
      <div style={{
        width: '300px',
        padding: '1rem',
        overflowY: 'auto',
        background: '#fafafa',
        position: 'relative',
        zIndex: 2
      }}>
        <SearchBar
          searchTerm={searchTerm}
          searchResults={searchResults}
          searching={searching}
          onChange={onSearchChange}
          onAdd={onAddToQueue}
          queue={queue}
        />
      </div>
      <div style={{ flex: 1, overflow: 'auto', position: 'relative', zIndex: 0, padding: '1rem' }}>
        {useFormUI ? (
          <ArtistRankingForm artists={queue} />
        ) : (
          <ArtistCanvas artists={queue} />
        )}
      </div>
    </div>
  )
}
