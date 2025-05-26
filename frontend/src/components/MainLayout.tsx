import ArtistCanvas from './ArtistCanvas'
import { SearchBar } from './SearchBar'
import type { Artist } from '../types'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onSearchChange: (term: string) => void
  onAddToQueue: (artist: Artist) => void
  queue: Artist[]
}

export function MainLayout({
  searchTerm,
  searchResults,
  searching,
  onSearchChange,
  onAddToQueue,
  queue,
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
      <div style={{ flex: 1, overflow: 'hidden', position: 'relative', zIndex: 0 }}>
        <ArtistCanvas artists={queue} />
      </div>
    </div>
  )
}
