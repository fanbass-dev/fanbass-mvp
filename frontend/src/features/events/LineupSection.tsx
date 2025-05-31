import type { Event, LineupEntry } from '../../types/types'

type Props = {
  event: Event
  lineup: LineupEntry[]
  onTierChange: (artistId: string, tier: number) => void
}

export function LineupSection({ event, lineup, onTierChange }: Props) {
  const grouped = Array.from({ length: event.num_tiers }, (_, i) =>
    lineup.filter((l) => l.tier === i + 1)
  )

  return (
    <>
      {grouped.map((group, i) => (
        <div key={i} style={{ marginTop: '1rem' }}>
          <h3>Tier {i + 1}</h3>
          {group.map((entry) => (
            <div
              key={entry.artist.id}
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '4px 0',
              }}
            >
              <span>{entry.artist.name}</span>
              <select
                value={entry.tier}
                onChange={(e) => onTierChange(entry.artist.id, Number(e.target.value))}
              >
                {Array.from({ length: event.num_tiers }, (_, j) => (
                  <option key={j + 1} value={j + 1}>
                    Tier {j + 1}
                  </option>
                ))}
              </select>
            </div>
          ))}
        </div>
      ))}
    </>
  )
}
