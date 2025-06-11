import { useState } from 'react'
import { ArtistRankingForm } from '../features/artists/ArtistRankingForm'
import ArtistCanvas from '../features/artists/pixiCanvas/ArtistCanvas'
import type { Artist } from '../types/types'
import './MainLayout.css'
import { SearchBar } from './SearchBar'
import type { Tier } from '../constants/tiers'
import { ChevronDown } from 'lucide-react'

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
  const [isSearchVisible, setIsSearchVisible] = useState(false)

  return (
    <div className="flex flex-col h-screen">
      <div className="sticky top-0 bg-surface shadow-md z-[45]">
        <div className="px-4 md:px-8 py-4 border-b border-gray-800">
          <div className="flex items-center justify-between">
            <h2>My Artist Rankings</h2>
            <button
              onClick={() => setIsSearchVisible(!isSearchVisible)}
              className="flex items-center gap-1 text-sm text-gray-400 hover:text-white transition"
            >
              <span>{isSearchVisible ? 'Hide Search' : 'Add Artists'} </span>
              <ChevronDown className={`w-4 h-4 transition-transform ${isSearchVisible ? 'rotate-180' : ''}`} />
            </button>
          </div>

          <div className={`transition-all duration-300 overflow-hidden ${isSearchVisible ? 'max-h-[500px] opacity-100' : 'max-h-0 opacity-0'}`}>
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
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-hidden px-4 md:px-8">
        <div className="h-full">
          {useFormUI ? (
            <ArtistRankingForm
              queue={myArtists}
              rankings={rankings}
              updateTier={updateTier}
              removeArtist={removeArtist}
              isSearchVisible={isSearchVisible}
            />
          ) : (
            <ArtistCanvas artists={myArtists} />
          )}
        </div>
      </div>
    </div>
  )
}
