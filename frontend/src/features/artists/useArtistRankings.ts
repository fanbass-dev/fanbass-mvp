// src/features/artists/useArtistRankings.ts

import { useEffect, useState } from 'react'
import { supabase } from '../../supabaseClient'
import { getCurrentUser } from '../../services/authService'
import { Artist } from '../../types/types'
import type { Tier } from '../../constants/tiers'

export function useArtistRankings() {
  const [user, setUser] = useState<any>(null)
  const [myArtists, setMyArtists] = useState<Artist[]>([])
  const [rankings, setRankings] = useState<Record<string, Tier>>({})

  useEffect(() => {
    const fetchData = async () => {
      const currentUser = await getCurrentUser()
      if (!currentUser) return
      setUser(currentUser)

      const { data: placements, error: placementError } = await supabase
        .from('artist_placements')
        .select('artist_id, b2b_set_id, tier')
        .eq('user_id', currentUser.id)

      if (placementError) {
        console.error('Error loading placements', placementError)
        return
      }

      const rankingsMap: Record<string, Tier> = {}
      for (const p of placements || []) {
        const key = p.artist_id || (p.b2b_set_id && `b2b-${p.b2b_set_id}`)
        if (key) {
          rankingsMap[key] = p.tier
        }
      }
      setRankings(rankingsMap)

      const artistIds = placements?.map(p => p.artist_id).filter(Boolean)
      const { data: artists } = await supabase
        .from('artists')
        .select('id, name')
        .in('id', artistIds || [])

      const b2bIds = placements?.map(p => p.b2b_set_id).filter(Boolean)
      const { data: b2bs } = await supabase
        .from('b2b_sets')
        .select('id, name, artist_ids')
        .in('id', b2bIds || [])

      const pseudoB2Bs: Artist[] = (b2bs || []).map((set) => ({
        id: `b2b-${set.id}`,
        name: set.name,
        is_b2b: true,
        original_ids: set.artist_ids,
      }))

      setMyArtists([...(artists || []), ...pseudoB2Bs])
    }

    fetchData()
  }, [])

  const addArtistToQueue = async (artist: Artist) => {
    setMyArtists((prev) => {
      if (prev.some((a) => a.id === artist.id)) return prev
      return [...prev, artist]
    })

    const isB2B = artist.id.startsWith('b2b-')
    const key = isB2B ? 'b2b_set_id' : 'artist_id'
    const value = isB2B ? artist.id.replace('b2b-', '') : artist.id

    const { error } = await supabase
      .from('artist_placements')
      .upsert(
        {
          user_id: user.id,
          [key]: value,
          tier: 'unranked',
        },
        {
          onConflict: `user_id,${key}`,
        }
      )

    if (error) {
      console.error('Failed to persist unranked placement:', error)
    } else {
      setRankings((prev) => ({
        ...prev,
        [artist.id]: 'unranked',
      }))
    }
  }

  const removeArtistFromQueue = async (id: string) => {
    if (!user) return

    const isB2B = id.startsWith('b2b-')
    const key = isB2B ? 'b2b_set_id' : 'artist_id'
    const value = isB2B ? id.replace('b2b-', '') : id

    const { error } = await supabase
      .from('artist_placements')
      .delete()
      .match({
        user_id: user.id,
        [key]: value,
      })

    if (error) {
      console.error('Failed to remove placement:', error)
      return
    }

    setMyArtists((prev) => prev.filter((a) => a.id !== id))
    setRankings((prev) => {
      const next = { ...prev }
      delete next[id]
      return next
    })
  }

  const updateTier = async (id: string, tier: Tier) => {
    if (!user) return

    const isB2B = id.startsWith('b2b-')
    const key = isB2B ? 'b2b_set_id' : 'artist_id'
    const value = isB2B ? id.replace('b2b-', '') : id

    const { error } = await supabase
      .from('artist_placements')
      .upsert(
        {
          user_id: user.id,
          [key]: value,
          tier,
        },
        {
          onConflict: `user_id,${key}`,
        }
      )

    if (error) {
      console.error('Failed to update tier:', error)
      return
    }

    setRankings((prev) => ({
      ...prev,
      [id]: tier,
    }))
  }

  return {
    myArtists,
    rankings,
    updateTier,
    addArtistToQueue,
    removeArtistFromQueue,
  }
}
