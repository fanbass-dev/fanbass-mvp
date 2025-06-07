import type { Tier } from '../constants/tiers'

export type Artist = {
  id: string
  name: string
} & Partial<{
  type: 'solo' | 'b2b'
  fingerprint: string
  member_ids: string[]
}>


export type Event = {
  id: string
  name: string
  date: string
  location: string
  num_tiers: number
  status?: string
  slug?: string
  created_by?: string
  created_at?: string
}

export type LineupEntry = {
  set_id: string
  tier: number
  artists: Artist[]
  set_note?: string
  display_name?: string
}
