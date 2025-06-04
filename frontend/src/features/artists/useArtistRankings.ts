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
        .select('artist_id, tier')
        .eq('user_id', currentUser.id)

      if (placementError) {
        console.error('Error loading placements', placementError)
        return
      }

      const rankingsMap: Record<string, Tier> = {}
      for (const p of placements || []) {
        rankingsMap[p.artist_id] = p.tier
      }
      setRankings(rankingsMap)

      const artistIds = placements?.map(p => p.artist_id).filter(Boolean)
      if (!artistIds?.length) {
        setMyArtists([])
        return
      }

      // First get the base artist information
      const { data: artists, error: artistError } = await supabase
        .from('artists')
        .select('id, name, type, fingerprint')
        .in('id', artistIds)
        .returns<Artist[]>()

      if (artistError) {
        console.error('Error loading artists', artistError)
        return
      }

      // For B2B artists, get their member IDs
      const b2bArtists = artists?.filter(a => a.type === 'b2b') || []
      if (b2bArtists.length > 0) {
        const { data: memberData, error: memberError } = await supabase
          .from('artist_members')
          .select('parent_artist_id, member_artist_id')
          .in('parent_artist_id', b2bArtists.map(a => a.id))

        if (memberError) {
          console.error('Error loading artist members', memberError)
        } else {
          // Group member IDs by artist
          const membersByArtist = memberData?.reduce((acc, { parent_artist_id, member_artist_id }) => {
            acc[parent_artist_id] = acc[parent_artist_id] || []
            acc[parent_artist_id].push(member_artist_id)
            return acc
          }, {} as Record<string, string[]>)

          // Add member_ids to the artists
          artists?.forEach(artist => {
            if (artist.type === 'b2b') {
              artist.member_ids = membersByArtist[artist.id] || []
            }
          })
        }
      }

      setMyArtists(artists || [])
    }

    fetchData()
  }, [])

  const addArtistToQueue = async (artist: Artist) => {
    setMyArtists((prev) => {
      if (prev.some((a) => a.id === artist.id)) return prev
      return [...prev, artist]
    })

    const { error } = await supabase
      .from('artist_placements')
      .upsert(
        {
          user_id: user.id,
          artist_id: artist.id,
          tier: 'unranked',
        },
        {
          onConflict: 'user_id,artist_id',
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

    const { error } = await supabase
      .from('artist_placements')
      .delete()
      .match({
        user_id: user.id,
        artist_id: id,
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

    // Optimistically update ranking to prevent flicker
    setRankings((prev) => ({
      ...prev,
      [id]: tier,
    }))

    const { error } = await supabase
      .from('artist_placements')
      .upsert(
        {
          user_id: user.id,
          artist_id: id,
          tier,
        },
        {
          onConflict: 'user_id,artist_id',
        }
      )

    if (error) {
      console.error('Failed to update tier:', error)
    }
  }

  return {
    myArtists,
    rankings,
    updateTier,
    addArtistToQueue,
    removeArtistFromQueue,
  }
}
