// src/types/types.ts

import type { Tier } from '../constants/tiers'

export type Artist = {
  id: string
  name: string
}

export type PlacedArtist = Artist & {
  stage: string
  tier: Tier
}

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
  tier: number
  artist: Artist
}
