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
    <div
      style={{
        display: 'flex',
        overflowX: 'auto',
        gap: '1rem',
        alignItems: 'flex-start',
      }}
    >
      {stages.map((stage) => (
        <div
          key={stage}
          style={{
            display: 'flex',
            flexDirection: 'column',
            flexGrow: 1,
            width: 'auto', // allow it to grow
          }}
        >
          <h3>{stage}</h3>

          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              gap: '0.75rem',
            }}
          >
            {tiers.map((tier) => {
              const id = dropKey(stage, tier)
              const artists = placements[id] ?? []

              return (
                <div
                  key={tier}
                  style={{
                    height: '150px',
                    display: 'flex',
                    flexDirection: 'column',
                  }}
                >
                  <strong style={{ marginBottom: '4px' }}>{tier.toUpperCase()}</strong>
                  <DroppableCell id={id} artists={artists} />
                </div>
              )
            })}
          </div>
        </div>
      ))}
    </div>
  )
}
