import { useEffect, useRef, useState } from 'react'
import type { Artist } from '../../types/types'
import { TIER_LABELS, type Tier } from '../../constants/tiers'
import { Trash, ChevronLeft, ChevronRight } from 'lucide-react'

type Props = {
  queue: Artist[]
  rankings: Record<string, Tier>
  updateTier: (id: string, tier: Tier) => void
  removeArtist?: (id: string) => void
}

export function ArtistRankingForm({ queue, rankings, updateTier, removeArtist }: Props) {
  const [notForMeExpanded, setNotForMeExpanded] = useState(false)
  const [menuOpenId, setMenuOpenId] = useState<string | null>(null)
  const [currentPage, setCurrentPage] = useState(1)
  const itemsPerPage = 10

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

  // Sort artists alphabetically within each tier
  Object.values(grouped).forEach(artists => {
    artists.sort((a, b) => a.name.localeCompare(b.name))
  })

  // Pagination for unranked section
  const unrankedArtists = grouped['unranked'] || []
  const totalPages = Math.ceil(unrankedArtists.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const endIndex = startIndex + itemsPerPage
  const currentUnrankedArtists = unrankedArtists.slice(startIndex, endIndex)

  const handlePageChange = (newPage: number) => {
    setCurrentPage(Math.max(1, Math.min(newPage, totalPages)))
  }

  return (
    <div className="relative z-10">
      <h2>My Artists</h2>
      {Object.keys(grouped).length === 0 ? (
        <p>No artists added yet. Use search to add.</p>
      ) : (
        (Object.keys(TIER_LABELS) as Tier[]).map((tier) => {
          const isNotForMe = tier === 'not_for_me'
          const isExpanded = !isNotForMe || notForMeExpanded
          const isUnranked = tier === 'unranked'
          const artists = isUnranked ? currentUnrankedArtists : (grouped[tier] || [])

          if (isNotForMe && artists.length === 0) return null

          return (
            <div key={tier} className="mb-8">
              <h3 className="flex justify-between items-center">
                <span>
                  {TIER_LABELS[tier]} ({grouped[tier]?.length || 0})
                </span>
                {isNotForMe && (
                  <button
                    onClick={() => setNotForMeExpanded(!notForMeExpanded)}
                    className="text-sm border border-gray-500 px-2 py-1 rounded"
                  >
                    {notForMeExpanded ? 'Hide' : 'Show'}
                  </button>
                )}
              </h3>

              {isExpanded && (
                <>
                  {artists.map((artist) => (
                    <div
                      key={artist.id}
                      className="flex items-center justify-between gap-3 mb-3 relative overflow-visible"
                    >
                      <div className="text-sm truncate basis-1/2">{artist.name}</div>

                      <div className="flex items-center gap-2 relative z-10">
                        <select
                          value={rankings[artist.id] || 'unranked'}
                          onChange={(e) => updateTier(artist.id, e.target.value as Tier)}
                          className="w-40 text-sm px-2 py-1 z-0"
                        >
                          {(Object.keys(TIER_LABELS) as Tier[]).map((t) => (
                            <option key={t} value={t}>
                              {TIER_LABELS[t]}
                            </option>
                          ))}
                        </select>
                        {removeArtist && (
                          <div
                            className="relative z-20"
                            ref={(el) => {
                              menuRefs.current[artist.id] = el
                            }}
                          >
                            <button
                              onClick={() =>
                                setMenuOpenId((prev) => (prev === artist.id ? null : artist.id))
                              }
                              className="text-white text-xl px-1"
                            >
                              ⋯
                            </button>
                            {menuOpenId === artist.id && (
                              <div className="absolute bottom-full right-0 mb-1 bg-gray-800 text-white border border-gray-600 rounded-md p-1 shadow-lg z-[9999]">
                                <button
                                  onClick={() => {
                                    removeArtist(artist.id)
                                    setMenuOpenId(null)
                                  }}
                                  className="flex items-center justify-center text-red-600 hover:text-red-700 p-1"
                                  aria-label="Remove artist"
                                >
                                  <Trash className="w-4 h-4" />
                                </button>
                              </div>
                            )}
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                  
                  {isUnranked && totalPages > 1 && (
                    <div className="flex items-center justify-center gap-4 mt-4">
                      <button
                        onClick={() => handlePageChange(currentPage - 1)}
                        disabled={currentPage === 1}
                        className="p-1 disabled:opacity-50"
                        aria-label="Previous page"
                      >
                        <ChevronLeft className="w-5 h-5" />
                      </button>
                      <span className="text-sm">
                        Page {currentPage} of {totalPages}
                      </span>
                      <button
                        onClick={() => handlePageChange(currentPage + 1)}
                        disabled={currentPage === totalPages}
                        className="p-1 disabled:opacity-50"
                        aria-label="Next page"
                      >
                        <ChevronRight className="w-5 h-5" />
                      </button>
                    </div>
                  )}
                </>
              )}
            </div>
          )
        })
      )}
    </div>
  )
}
