import { useEffect, useState } from 'react'
import { supabase } from '../supabaseClient'
import type { Artist } from '../types'

export function useArtistSearch(searchTerm: string) {
  const [searchResults, setSearchResults] = useState<Artist[]>([])
  const [searching, setSearching] = useState(false)

  useEffect(() => {
    if (!searchTerm.trim()) {
      setSearchResults([])
      return
    }

    setSearching(true)

    supabase
      .from('artists')
      .select('id, name')
      .ilike('name', `%${searchTerm}%`)
      .then(({ data, error }) => {
        setSearching(false)
        if (error) {
          console.error('Search failed:', error)
        } else {
          setSearchResults(data || [])
        }
      })
  }, [searchTerm])

  return { searchResults, searching }
}
