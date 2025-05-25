export type Artist = {
  id: string
  name: string
  stage: string
  tier: 'headliner' | 'support' | 'opener'
}

export type Tier = 'headliner' | 'support' | 'opener'
