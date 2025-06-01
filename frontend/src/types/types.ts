import type { Tier } from '../constants/tiers'

export type Artist = {
  id: string
  name: string
} & Partial<{
  is_b2b: boolean
  original_ids: string[]
}>


export type Event = {
  id: string
  name: string
  date: string
  location: string
  num_tiers: number
  status?: string
  slug?: string
}

export type LineupEntry = {
  set_id: string
  tier: number
  artists: Artist[]
  set_note?: string
  display_name?: string
}
