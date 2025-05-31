import { supabase } from '../supabaseClient'
import { Artist } from '../types/types'
import type { Tier } from '../constants/tiers'

export async function fetchArtists(): Promise<Artist[]> {
  const { data, error } = await supabase.from('artists').select('*')
  if (error) throw error
  return data ?? []
}

export async function fetchUserRankings(userId: string): Promise<{ artist_id: string; tier: Tier; updated_at: string }[]> {
  const { data, error } = await supabase
    .from('artist_placements')
    .select('artist_id,tier,updated_at')
    .eq('user_id', userId)

  if (error) throw error
  return data ?? []
}

export async function upsertRankings(
  payload: { user_id: string; artist_id: string; tier: Tier }[]
) {
  const { error } = await supabase.from('artist_placements').upsert(payload, {
    onConflict: 'user_id,artist_id',
  })
  if (error) throw error
}

export async function insertRankingHistory(
  payload: { user_id: string; artist_id: string; tier: Tier }[]
) {
  const { error } = await supabase.from('artist_placement_history').insert(payload)
  if (error) throw error
}
