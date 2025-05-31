import { useEffect, useRef, useState } from 'react'
import type { Artist } from '../../types/types'
import { TIER_LABELS, type Tier } from '../../constants/tiers'

type Props = {
  queue: Artist[]
  rankings: Record<string, Tier>
  updateTier: (id: string, tier: Tier) => void
  removeArtist?: (id: string) => void
}

export function ArtistRankingForm({ queue, rankings, updateTier, removeArtist }: Props) {
  const [notForMeExpanded, setNotForMeExpanded] = useState(false)
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

  const grouped: Record<Tier, Artist[]> = {} as Record<Tier, Artist[]>
  queue.forEach((artist) => {
    const tier = rankings[artist.id] || 'unranked'
    if (!grouped[tier]) grouped[tier] = []
    grouped[tier].push(artist)
  })

  return (
    <div>
      <h2>My Artists</h2>
      {Object.keys(grouped).length === 0 ? (
        <p>No artists added yet. Use search to add.</p>
      ) : (
        (Object.keys(TIER_LABELS) as Tier[]).map((tier) => {
          const isNotForMe = tier === 'not_for_me'
          const isExpanded = !isNotForMe || notForMeExpanded
          const artists = grouped[tier] || []

          if (isNotForMe && artists.length === 0) return null

          return (
            <div key={tier} style={{ marginBottom: '2rem' }}>
              <h3 style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span>
                  {TIER_LABELS[tier]} ({artists.length})
                </span>
                {isNotForMe && (
                  <button
                    onClick={() => setNotForMeExpanded(!notForMeExpanded)}
                    style={{
                      fontSize: '0.9rem',
                      padding: '4px 8px',
                      border: '1px solid #ccc',
                      borderRadius: '4px',
                      cursor: 'pointer',
                    }}
                  >
                    {notForMeExpanded ? 'Hide' : 'Show'}
                  </button>
                )}
              </h3>

              {isExpanded &&
                artists.map((artist) => (
                  <div
                    key={artist.id}
                    style={{
                      display: 'flex',
                      flexDirection: 'row',
                      flexWrap: 'nowrap',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      gap: '12px',
                      marginBottom: '12px',
                      flexGrow: 1,
                      overflowX: 'auto',
                    }}
                  >
                    <div
                      style={{
                        minWidth: 0,
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                        whiteSpace: 'nowrap',
                        fontSize: '0.95rem',
                        flexBasis: '50%',
                      }}
                    >
                      {artist.name}
                    </div>

                    <div
                      style={{
                        display: 'flex',
                        flex: '2 1 240px',
                        alignItems: 'center',
                        justifyContent: 'flex-end',
                        gap: '8px',
                        minWidth: 0,
                        position: 'relative',
                      }}
                    >
                      <select
                        value={rankings[artist.id] || 'unranked'}
                        onChange={(e) => updateTier(artist.id, e.target.value as Tier)}
                        style={{
                          width: '160px', // fixed width for label length
                          fontSize: '0.95rem',
                          padding: '4px 6px',
                        }}
                      >
                        {(Object.keys(TIER_LABELS) as Tier[]).map((t) => (
                          <option key={t} value={t}>
                            {TIER_LABELS[t]}
                          </option>
                        ))}
                      </select>

                      {removeArtist && (
                        <div
                          style={{ position: 'relative' }}
                          ref={(el) => {
                            menuRefs.current[artist.id] = el
                          }}
                        >
                          <button
                            onClick={() =>
                              setMenuOpenId((prev) => (prev === artist.id ? null : artist.id))
                            }
                            style={{
                              background: 'transparent',
                              border: 'none',
                              fontSize: '1.2rem',
                              cursor: 'pointer',
                              padding: '0 6px',
                              lineHeight: 1,
                            }}
                          >
                            ⋯
                          </button>
                          {menuOpenId === artist.id && (
                            <div
                              style={{
                                position: 'absolute',
                                bottom: '100%',
                                right: 0,
                                background: 'white',
                                border: '1px solid #ccc',
                                borderRadius: '4px',
                                padding: '4px 8px',
                                zIndex: 10,
                                whiteSpace: 'nowrap',
                              }}
                            >
                              <button
                                onClick={() => {
                                  removeArtist(artist.id)
                                  setMenuOpenId(null)
                                }}
                                style={{
                                  background: 'none',
                                  border: 'none',
                                  color: 'red',
                                  cursor: 'pointer',
                                  padding: '4px 0',
                                }}
                              >
                                Remove
                              </button>
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  </div>
                ))}
            </div>
          )
        })
      )}
    </div>
  )
}
