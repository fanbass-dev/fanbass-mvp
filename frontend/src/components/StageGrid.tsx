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
          display: 'grid',
          gridTemplateColumns: `repeat(${stages.length}, 220px)`,
          gap: '12px',
        }}
      >
        {stages.map((stage) => (
          <div key={stage}>
            <h3 style={{ textAlign: 'center' }}>{stage}</h3>
            <div
              style={{
                display: 'grid',
                gridTemplateRows: `repeat(${tiers.length}, 160px)`,
                gap: '12px',
              }}
            >
              {tiers.map((tier) => {
                const id = dropKey(stage, tier)
                const artists = placements[id] ?? []

                return (
                  <div key={tier}>
                    <strong style={{ fontSize: 12 }}>{tier.toUpperCase()}</strong>
                    <GridCell id={id} artists={artists} />
                  </div>
                )
              })}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
