import { DroppableCell } from './DroppableCell'
import type { Artist } from '../types'
import type { Tier } from '../types'

type Props = {
  stages: string[]
  tiers: Tier[]
  placements: Record<string, Artist[]>
  dropKey: (stage: string, tier: Tier) => string
}

export function StageGrid({ stages, tiers, placements, dropKey }: Props) {
  return (
    <div style={{ display: 'flex', overflowX: 'auto' }}>
      {stages.map((stage) => (
        <div key={stage} style={{ marginRight: '1rem', minWidth: '150px' }}>
          <h3>{stage}</h3>
          {tiers.map((tier) => {
            const id = dropKey(stage, tier)
            const artists = placements[id] ?? []

            return (
              <div key={tier} style={{ marginBottom: '1rem' }}>
                <strong>{tier.toUpperCase()}</strong>
                <DroppableCell id={id} artists={artists} />
              </div>
            )
          })}
        </div>
      ))}
    </div>
  )
}
