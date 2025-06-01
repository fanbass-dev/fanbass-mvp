import { ArtistRankingForm } from '../features/artists/ArtistRankingForm'
import ArtistCanvas from '../features/artists/pixiCanvas/ArtistCanvas'
import type { Artist } from '../types/types'
import './MainLayout.css'
import { SearchBar } from './SearchBar'
import { useArtistRankings } from '../features/artists/useArtistRankings'
import { supabase } from '../supabaseClient'

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
    myArtists,
    rankings,
    updateTier,
    removeArtistFromQueue,
    addArtistToQueue,
  } = useArtistRankings()

  const handleAddArtistOrB2B = async (artistOrArtists: Artist | Artist[]) => {
    if (Array.isArray(artistOrArtists)) {
      const sortedIds = artistOrArtists.map((a) => a.id).sort()
      const name = artistOrArtists.map((a) => a.name).join(' B2B')

      const { data: user } = await supabase.auth.getUser()
      const userId = user?.user?.id
      if (!userId) return

      // Check for existing B2B set with same artist_ids
      const { data: existingB2Bs, error: fetchError } = await supabase
        .from('b2b_sets')
        .select('id, name, artist_ids')
        .eq('created_by', userId)

      if (fetchError) {
        console.error('Failed to check for existing B2Bs:', fetchError)
        return
      }

      const match = existingB2Bs?.find(
        (set) =>
          set.artist_ids.length === sortedIds.length &&
          [...set.artist_ids].sort().every((id, i) => id === sortedIds[i])
      )

      let b2bId: string
      let b2bName: string

      if (match) {
        b2bId = match.id
        b2bName = match.name
      } else {
        const { data: newB2B, error: insertError } = await supabase
          .from('b2b_sets')
          .insert({
            name,
            artist_ids: sortedIds,
            created_by: userId,
          })
          .select()
          .single()

        if (insertError || !newB2B) {
          console.error('Failed to insert B2B set:', insertError)
          return
        }

        b2bId = newB2B.id
        b2bName = newB2B.name
      }

      const pseudoArtist: Artist = {
        id: `b2b-${b2bId}`,
        name: b2bName,
        is_b2b: true,
        original_ids: sortedIds,
      }

      // Remove individuals to avoid duplication
      sortedIds.forEach(removeArtistFromQueue)

      // Add to UI immediately
      addArtistToQueue(pseudoArtist)

      // Persist ranking to trigger re-load on future visits
      await updateTier(pseudoArtist.id, 'unranked')
    } else {
      addArtistToQueue(artistOrArtists)
    }
  }

  const handleRemove = (id: string) => {
    removeArtistFromQueue(id)
  }

  return (
    <div className="layout">
      <div className="sidebar">
        <SearchBar
          searchTerm={searchTerm}
          searchResults={searchResults}
          searching={searching}
          onChange={onSearchChange}
          onAdd={handleAddArtistOrB2B}
          queue={myArtists}
        />
      </div>
      <div className="mainContent">
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
