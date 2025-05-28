export type Artist = {
  id: string
  name: string
}

export type Tier =
  | 'must_see'
  | 'worth_the_effort'
  | 'nice_to_catch'
  | 'depends_on_context'
  | 'unranked'

export const TIER_LABELS: Record<Tier, string> = {
  must_see: 'Must See',
  worth_the_effort: 'Worth the Effort',
  nice_to_catch: 'Cool If I Catch It',
  depends_on_context: 'Would Go with the Right Vibe',
  unranked: 'Unranked',
}

export type PlacedArtist = Artist & {
  stage: string
  tier: Tier
}
