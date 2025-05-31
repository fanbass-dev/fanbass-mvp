import { useEffect, useState } from 'react'
import { supabase } from '../../supabaseClient'
import { Artist } from '../../types/types'
import type { Tier } from '../../constants/tiers'
import { useUserContext } from '../../context/UserContext'

export function useArtistRankings() {
  const { user } = useUserContext()
  const [myArtists, setMyArtists] = useState<Artist[]>([])
  const [rankings, setRankings] = useState<Record<string, Tier>>({})

  useEffect(() => {
    const fetchData = async () => {
      if (!user) return

      const { data: placements, error: placementError } = await supabase
        .from('artist_placements')
        .select('artist_id, tier')
        .eq('user_id', user.id)

      if (placementError) {
        console.error('Error fetching artist placements:', placementError)
        return
      }

      const artistIds = placements.map((p) => p.artist_id)
      const { data: artistData, error: artistError } = await supabase
        .from('artists')
        .select('*')
        .in('id', artistIds)

      if (artistError) {
        console.error('Error fetching artists:', artistError)
        return
      }

      const initialRankings: Record<string, Tier> = {}
      placements.forEach((p) => {
        initialRankings[p.artist_id] = p.tier
      })

      setMyArtists(artistData || [])
      setRankings(initialRankings)
    }

    fetchData()
  }, [user])

  const updateTier = async (artistId: string, tier: Tier) => {
    if (!user) return
    setRankings((prev) => ({ ...prev, [artistId]: tier }))

    const payload = {
      user_id: user.id,
      artist_id: artistId,
      tier,
    }

    await supabase
      .from('artist_placements')
      .upsert(payload, { onConflict: 'user_id,artist_id' })

    await supabase
      .from('artist_placement_history')
      .insert(payload)
  }

  const addArtistToQueue = async (artist: Artist) => {
    if (!user) return

    const payload = {
      user_id: user.id,
      artist_id: artist.id,
      tier: 'unranked' as Tier,
    }

    await supabase
      .from('artist_placements')
      .upsert(payload, { onConflict: 'user_id,artist_id' })

    await supabase
      .from('artist_placement_history')
      .insert(payload)

    setMyArtists((prev) => {
      if (prev.find((a) => a.id === artist.id)) return prev
      return [...prev, artist]
    })

    setRankings((prev) => ({
      ...prev,
      [artist.id]: 'unranked',
    }))
  }

  const removeArtistFromQueue = async (artistId: string) => {
    if (!user) return

    await supabase
      .from('artist_placements')
      .delete()
      .eq('user_id', user.id)
      .eq('artist_id', artistId)

    setMyArtists((prev) => prev.filter((a) => a.id !== artistId))
    setRankings((prev) => {
      const { [artistId]: _, ...rest } = prev
      return rest
    })
  }

  return {
    user,
    myArtists,
    rankings,
    updateTier,
    addArtistToQueue,
    removeArtistFromQueue,
  }
}
