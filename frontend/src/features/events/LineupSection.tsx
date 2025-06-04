import { useEffect, useRef, useState, useMemo } from 'react'
import type { Event, LineupEntry } from '../../types/types'
import { deleteLineupEntry } from './useEvent'
import { Trash } from 'lucide-react'

type Props = {
  event: Event
  lineup: LineupEntry[]
  setLineup: React.Dispatch<React.SetStateAction<LineupEntry[]>>
  onTierChange: (artistId: string, tier: number) => void
  onSetNoteChange: (artistId: string, note: string) => void
}

export function LineupSection({ event, lineup, setLineup, onTierChange, onSetNoteChange }: Props) {
  const [menuOpenId, setMenuOpenId] = useState<string | null>(null)
  const menuRefs = useRef<Record<string, HTMLDivElement | null>>({})

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        menuOpenId &&
        menuRefs.current[menuOpenId] &&
        !menuRefs.current[menuOpenId]!.contains(event.target as Node)
      ) {
        setMenuOpenId(null)
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [menuOpenId])

  const grouped = useMemo(() => {
    const groups: LineupEntry[][] = []
    for (let i = 0; i < (event?.num_tiers || 3); i++) {
      groups.push(lineup.filter((entry) => entry.tier === i + 1))
    }
    return groups
  }, [lineup, event?.num_tiers])

  const getDisplayName = (entry: LineupEntry) => {
    if (entry.display_name) return entry.display_name
    
    // If any of the artists is a B2B, use its name
    const b2bArtist = entry.artists.find(a => a.type === 'b2b')
    if (b2bArtist) return b2bArtist.name
    
    // Otherwise join artist names with B2B if multiple
    return entry.artists.length > 1
      ? entry.artists.map(a => a.name).join(' B2B ')
      : entry.artists[0].name
  }

  return (
    <>
      {grouped.map((group, i) => (
        <div key={i} style={{ marginTop: '1rem' }}>
          <h3>Tier {i + 1}</h3>
          {group.map((entry) => {
            const nameToShow = getDisplayName(entry)
            const primaryId = entry.artists[0]?.id || `set-${i}`
            const uniqueKey = entry.set_id

            return (
              <div
                key={uniqueKey}
                className="flex flex-col md:flex-row md:items-center justify-between gap-2 py-2 relative"
              >
                <div className="flex flex-row items-center gap-2">
                  <span className="font-medium">{nameToShow}</span>
                  {entry.set_note && (
                    <input
                      type="text"
                      className="bg-gray-800 border border-gray-600 rounded px-2 py-1 text-sm"
                      value={entry.set_note}
                      size={Math.max(entry.set_note.length, 1)}
                      onChange={(e) =>
                        onSetNoteChange(primaryId, e.target.value)
                      }
                    />
                  )}
                </div>

                <div className="flex items-center gap-2">
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

                  <div
                    className="relative z-20"
                    ref={(el) => {
                      menuRefs.current[uniqueKey] = el
                    }}
                  >
                    <button
                      onClick={() =>
                        setMenuOpenId((prev) => (prev === uniqueKey ? null : uniqueKey))
                      }
                      className="text-white text-xl px-1"
                    >
                      ⋯
                    </button>
                    {menuOpenId === uniqueKey && (
                      <div className="absolute bottom-full right-0 mb-1 bg-gray-800 text-white border border-gray-600 rounded-md p-1 shadow-lg z-[9999]">
                        <button
                          onClick={async () => {
                            const success = await deleteLineupEntry(event.id, entry.set_id)
                            if (success) {
                              setLineup((prev) => prev.filter((l) => l.set_id !== entry.set_id))
                            }
                          }}
                          className="flex items-center justify-center text-red-600 hover:text-red-700 p-1"
                          aria-label="Remove set"
                        >
                          <Trash className="w-4 h-4" />
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      ))}
    </>
  )
}
