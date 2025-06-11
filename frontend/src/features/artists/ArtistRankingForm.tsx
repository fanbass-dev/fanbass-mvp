import { useEffect, useRef, useState } from 'react'
import type { Artist } from '../../types/types'
import { TIER_LABELS, type Tier } from '../../constants/tiers'
import { Trash, ChevronLeft, ChevronRight, ChevronDown } from 'lucide-react'

type Props = {
  queue: Artist[]
  rankings: Record<string, Tier>
  updateTier: (id: string, tier: Tier) => void
  removeArtist?: (id: string) => void
  isSearchVisible: boolean
}

function RankDropdown({ 
  artistId, 
  currentTier, 
  onUpdateTier 
}: { 
  artistId: string
  currentTier: Tier
  onUpdateTier: (id: string, tier: Tier) => void 
}) {
  const [isOpen, setIsOpen] = useState(false)
  const dropdownRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  return (
    <div className="relative" ref={dropdownRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-24 text-sm pl-3 pr-8 py-1.5 bg-gray-800 border border-gray-700 rounded hover:bg-gray-700 transition-colors flex items-center justify-between relative z-[1]"
      >
        <span className="text-gray-300">Rank</span>
        <ChevronDown className="absolute right-2 w-4 h-4 text-gray-400" />
      </button>
              {isOpen && (
          <div className="absolute top-full right-0 mt-1 w-36 bg-gray-800 border border-gray-700 rounded shadow-lg py-1 z-[41]">
          {(Object.keys(TIER_LABELS) as Tier[]).map((tier) => (
            <button
              key={tier}
              onClick={() => {
                onUpdateTier(artistId, tier)
                setIsOpen(false)
              }}
              className={`w-full text-left px-3 py-1.5 text-sm hover:bg-gray-700 transition-colors ${
                tier === currentTier ? 'bg-gray-700' : ''
              }`}
            >
              {TIER_LABELS[tier]}
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

export function ArtistRankingForm({ queue, rankings, updateTier, removeArtist, isSearchVisible }: Props) {
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
    <div className="relative">
      {Object.keys(grouped).length === 0 ? (
        <p>No artists added yet. Use search to add.</p>
      ) : (
        <div className="h-[calc(100vh-180px)] overflow-y-auto">
          {(Object.keys(TIER_LABELS) as Tier[]).map((tier) => {
            const isNotForMe = tier === 'not_for_me'
            const isExpanded = !isNotForMe || notForMeExpanded
            const isUnranked = tier === 'unranked'
            const artists = isUnranked ? currentUnrankedArtists : (grouped[tier] || [])

            if (isNotForMe && artists.length === 0) return null

            return (
              <div key={tier} className="mb-8">
                <div className={`sticky top-0 bg-surface z-[40] border-b border-gray-800 shadow-sm py-3`}>
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
                </div>

                {isExpanded && (
                  <div className="mt-3">
                    {artists.map((artist) => (
                      <div
                        key={artist.id}
                        className="flex items-center justify-between gap-3 mb-3 relative overflow-visible"
                      >
                        <div className="text-sm truncate basis-1/2">{artist.name}</div>

                        <div className="flex items-center gap-2 relative">
                          <RankDropdown
                            artistId={artist.id}
                            currentTier={rankings[artist.id] || 'unranked'}
                            onUpdateTier={updateTier}
                          />
                          {removeArtist && (
                            <div
                              className="relative z-[40]"
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
                                <div className="absolute bottom-full right-0 mb-1 bg-gray-800 text-white border border-gray-600 rounded-md p-1 shadow-lg z-[41]">
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
                  </div>
                )}
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}
