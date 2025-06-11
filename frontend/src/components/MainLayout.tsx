import { ArtistRankingForm } from '../features/artists/ArtistRankingForm'
import ArtistCanvas from '../features/artists/pixiCanvas/ArtistCanvas'
import type { Artist } from '../types/types'
import './MainLayout.css'
import { SearchBar } from './SearchBar'
import type { Tier } from '../constants/tiers'

type Props = {
  searchTerm: string
  searchResults: Artist[]
  searching: boolean
  onSearchChange: (term: string) => void
  onAddToQueue: (artist: Artist) => void
  useFormUI: boolean
  myArtists: Artist[]
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
  useFormUI,
  myArtists,
  rankings,
  updateTier,
  removeArtist,
}: Props) {
  return (
    <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6 text-white">
      <h2>My Artist Rankings</h2>
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
            removeArtist={removeArtist}
          />
        ) : (
          <ArtistCanvas artists={myArtists} />
        )}
      </div>
    </div>
  )
}
