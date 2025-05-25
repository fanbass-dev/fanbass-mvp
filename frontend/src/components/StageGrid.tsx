import { GridCell } from './GridCell'
import type { Artist, Tier } from '../types'

type Props = {
  stages: string[]
  tiers: Tier[]
  placements: Record<string, Artist[]>
  dropKey: (stage: string, tier: Tier) => string
}

export function StageGrid({ stages, tiers, placements, dropKey }: Props) {
  return (
    <div style={{ overflowX: 'auto' }}>
      <div
        style={{
          display: 'flex',
          gap: '16px',
          alignItems: 'flex-start',
        }}
      >
        {stages.map((stage) => (
          <div
            key={stage}
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'stretch',
              width: 'max-content',
              flex: '0 0 auto',
            }}
          >
            <h3 style={{ textAlign: 'center' }}>{stage}</h3>
            {tiers.map((tier) => {
              const id = dropKey(stage, tier)
              const artists = placements[id] ?? []

              return (
                <div key={tier} style={{ height: '170px', marginBottom: '12px' }}>
                  <strong style={{ fontSize: 12 }}>{tier.toUpperCase()}</strong>
                  <GridCell id={id} artists={artists} />
                </div>
              )
            })}
          </div>
        ))}
      </div>
    </div>
  )
}
