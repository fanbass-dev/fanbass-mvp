import type { Event, LineupEntry } from '../../types/types'

type Props = {
  event: Event
  lineup: LineupEntry[]
  onTierChange: (artistId: string, tier: number) => void
  onSetNoteChange: (artistId: string, note: string) => void
}

export function LineupSection({ event, lineup, onTierChange, onSetNoteChange }: Props) {
  const grouped = Array.from({ length: event.num_tiers }, (_, i) =>
    lineup.filter((l) => l.tier === i + 1)
  )

  return (
    <>
      {grouped.map((group, i) => (
        <div key={i} style={{ marginTop: '1rem' }}>
          <h3>Tier {i + 1}</h3>
          {group.map((entry, index) => {
            const nameToShow =
              entry.display_name || entry.artists.map((a) => a.name).join(' B2B ')
            const primaryId = entry.artists[0]?.id || `set-${index}`

            return (
              <div
                key={primaryId}
                className="flex flex-col md:flex-row md:items-center justify-between gap-2 py-2"
              >
                <div className="flex flex-col">
                  <span className="font-medium">{nameToShow}</span>
                  <input
                    type="text"
                    className="bg-gray-800 border border-gray-600 rounded px-2 py-1 text-sm mt-1"
                    placeholder="Set note (optional)"
                    value={entry.set_note ?? ''}
                    onChange={(e) =>
                      onSetNoteChange(primaryId, e.target.value)
                    }
                  />
                </div>

                <select
                  value={entry.tier}
                  onChange={(e) =>
                    onTierChange(primaryId, Number(e.target.value))
                  }
                  className="bg-gray-800 border border-gray-600 rounded px-2 py-1 text-sm"
                >
                  {Array.from({ length: event.num_tiers }, (_, j) => (
                    <option key={j + 1} value={j + 1}>
                      Tier {j + 1}
                    </option>
                  ))}
                </select>
              </div>
            )
          })}
        </div>
      ))}
    </>
  )
}
