export type Artist = {
  id: string
  name: string
}

export type Tier = 'headliner' | 'support' | 'opener'

export type PlacedArtist = Artist & {
  stage: string
  tier: Tier
}
