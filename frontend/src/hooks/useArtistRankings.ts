import { useEffect, useState } from 'react'
import { supabase } from '../supabaseClient'
import { Artist, Tier } from '../types'

export function useArtistRankings() {
  const [user, setUser] = useState<any>(null)
  const [artists, setArtists] = useState<Artist[]>([])
  const [rankings, setRankings] = useState<Record<string, Tier>>({})

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => setUser(data?.user ?? null))

    supabase
      .from('artists')
      .select('*')
      .then(({ data, error }) => {
        if (error) {
          console.error('Error fetching artists:', error)
        } else if (data) {
          setArtists(data)
        }
      })
  }, [])

  const updateTier = (artistId: string, tier: Tier) => {
    setRankings((prev) => ({ ...prev, [artistId]: tier }))
  }

  const submit = async () => {
    if (!user) throw new Error('User not logged in')

    const payload = Object.entries(rankings).map(([artist_id, tier]) => ({
      user_id: user.id,
      artist_id,
      tier,
    }))

    const { error } = await supabase.from('artist_rankings').upsert(payload, {
    onConflict: 'user_id,artist_id',
    })

    if (error) throw error
  }

  return {
    user,
    artists,
    rankings,
    updateTier,
    submit,
  }
}
