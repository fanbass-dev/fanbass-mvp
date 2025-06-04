// src/features/events/useEventRankings.ts
import { useEffect, useState } from 'react'
import { supabase } from '../../supabaseClient'
import type { Tier } from '../../constants/tiers'

export function useEventRankings(artistIds: string[]) {
  const [rankings, setRankings] = useState<Record<string, Tier>>({})
  const [userId, setUserId] = useState<string | null>(null)

  useEffect(() => {
    const fetchData = async () => {
      const {
        data: { session },
      } = await supabase.auth.getSession()
      const user = session?.user
      if (!user) return

      setUserId(user.id)

      // Get all artist placements for this user
      const { data, error } = await supabase
        .from('artist_placements')
        .select('artist_id, tier')
        .eq('user_id', user.id)
        .in('artist_id', artistIds)

      if (error || !data) return

      const eventFiltered: Record<string, Tier> = {}
      data.forEach((row: { artist_id: string; tier: Tier }) => {
        eventFiltered[row.artist_id] = row.tier
      })

      setRankings(eventFiltered)
    }

    fetchData()
  }, [artistIds])

  const updateTier = async (artistId: string, tier: Tier) => {
    if (!userId) return
    setRankings((prev) => ({ ...prev, [artistId]: tier }))

    await supabase
      .from('artist_placements')
      .upsert({ user_id: userId, artist_id: artistId, tier }, {
        onConflict: 'user_id,artist_id'
      })
  }

  return { rankings, updateTier }
}
