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
  myArtists: Artist[]
}

export function MainLayout({
  searchTerm,
  searchResults,
  searching,
  onSearchChange,
  onAddToQueue,
  useFormUI,
  myArtists,
}: Props) {
  const {
    rankings,
    updateTier,
    removeArtistFromQueue,
  } = useArtistRankings()

  const handleRemove = (id: string) => {
    removeArtistFromQueue(id)
  }

  return (
    <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6 text-white">
      <SearchBar
        searchTerm={searchTerm}
        searchResults={searchResults}
        searching={searching}
        onChange={onSearchChange}
        onAdd={(artistOrArtists) => {
          if (Array.isArray(artistOrArtists)) {
            console.warn('Received array of artists - this should not happen with new schema')
            return
          }
          onAddToQueue(artistOrArtists)
        }}
        queue={myArtists}
      />

      <div className="mt-6">
        {useFormUI ? (
          <ArtistRankingForm
            queue={myArtists}
            rankings={rankings}
            updateTier={updateTier}
            removeArtist={handleRemove}
          />
        ) : (
          <ArtistCanvas artists={myArtists} />
        )}
      </div>
    </div>
  )
}
