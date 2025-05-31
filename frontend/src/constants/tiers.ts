// src/constants/tiers.ts
export type Tier =
  | 'must_see'
  | 'worth_the_effort'
  | 'nice_to_catch'
  | 'depends_on_context'
  | 'not_for_me'
  | 'unranked'

export const TIER_LABELS: Record<Tier, string> = {
  must_see: 'Must see',
  worth_the_effort: 'Worth the effort',
  nice_to_catch: 'Cool if I catch It',
  depends_on_context: 'Only going if the homies go',
  not_for_me: 'Not for me',
  unranked: 'Unranked',
}
