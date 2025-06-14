import { useEffect, useRef, useState } from 'react'
import type { Artist } from '../../types/types'
import { TIER_LABELS, type Tier } from '../../constants/tiers'
import { Trash, ChevronLeft, ChevronRight, ChevronDown, Pencil } from 'lucide-react'

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
    <div className="relative debug-dropdown" ref={dropdownRef}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="h-7 px-2 text-sm text-gray-300 hover:text-white transition-colors flex items-center gap-1 debug-dropdown-button"
      >
        <span>Rank</span>
        <ChevronDown className="w-4 h-4" />
      </button>
      {isOpen && (
        <div className="absolute top-full right-0 mt-1 w-36 bg-gray-800 border border-gray-700 rounded shadow-lg py-1 z-[41] debug-dropdown-content">
          {(Object.keys(TIER_LABELS) as Tier[]).map((tier) => (
            <button
              key={tier}
              onClick={() => {
                onUpdateTier(artistId, tier)
                setIsOpen(false)
              }}
              className={`w-full text-left px-3 py-1.5 text-sm hover:bg-gray-700 transition-colors ${
                tier === currentTier ? 'bg-gray-700' : ''
              } debug-dropdown-item`}
            >
              {TIER_LABELS[tier]}
            </button>
          ))}
        </div>
      )}
    </div>
  )
}

const ITEMS_PER_PAGE = 10

function DeleteConfirmationModal({
  artist,
  onConfirm,
  onCancel,
}: {
  artist: Artist
  onConfirm: () => void
  onCancel: () => void
}) {
  // Close on escape key
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onCancel()
    }
    window.addEventListener('keydown', handleEscape)
    return () => window.removeEventListener('keydown', handleEscape)
  }, [onCancel])

  const handleOverlayClick = (e: React.MouseEvent) => {
    // Only close if clicking the overlay itself, not its children
    if (e.target === e.currentTarget) {
      onCancel()
    }
  }

  return (
    <div 
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      onClick={handleOverlayClick}
    >
      <div className="bg-gray-800 rounded-lg p-3 max-w-sm w-full mx-4 shadow-xl">
        <div className="mb-2">
          <h3 className="text-lg">Remove Ranking</h3>
        </div>
        <p className="mb-3">Remove <span className="font-medium">{artist.name}</span> from your rankings?</p>
        <div className="flex justify-end gap-3">
          <button
            onClick={onCancel}
            className="px-4 py-1.5 text-sm text-gray-300 hover:text-white transition-colors rounded bg-gray-700/50 hover:bg-gray-700"
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            className="px-4 py-1.5 text-sm text-red-500 hover:text-red-400 transition-colors rounded bg-red-500/10 hover:bg-red-500/20"
          >
            Remove
          </button>
        </div>
      </div>
    </div>
  )
}

function PaginatedArtistList({
  artists,
  rankings,
  updateTier,
  removeArtist,
  currentPage,
  onPageChange,
  isUnranked = false,
}: {
  artists: Artist[]
  rankings: Record<string, Tier>
  updateTier: (id: string, tier: Tier) => void
  removeArtist?: (id: string) => void
  currentPage: number
  onPageChange: (page: number) => void
  isUnranked?: boolean
}) {
  const [menuOpenId, setMenuOpenId] = useState<string | null>(null)
  const [deleteModalArtist, setDeleteModalArtist] = useState<Artist | null>(null)
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

  const startIndex = (currentPage - 1) * ITEMS_PER_PAGE
  const currentArtists = artists.slice(startIndex, startIndex + ITEMS_PER_PAGE)

  const handleDelete = (artist: Artist) => {
    setDeleteModalArtist(artist)
  }

  const handleConfirmDelete = () => {
    if (deleteModalArtist && removeArtist) {
      removeArtist(deleteModalArtist.id)
      setMenuOpenId(null)
    }
    setDeleteModalArtist(null)
  }

  return (
    <div className="mt-2">
      {currentArtists.map((artist) => (
        <div
          key={artist.id}
          className="flex items-center justify-between gap-3 mb-2 relative overflow-visible"
        >
          <div className="text-sm truncate basis-1/2">{artist.name}</div>
          <div className="flex items-center gap-2 relative">
            {removeArtist && (
              isUnranked ? (
                <div className="relative flex items-center gap-1">
                  <div className="bg-gray-800 text-white border border-gray-600 rounded-md shadow-lg flex items-center">
                    <RankDropdown
                      artistId={artist.id}
                      currentTier={rankings[artist.id] || 'unranked'}
                      onUpdateTier={updateTier}
                    />
                    {rankings[artist.id] === 'unranked' && (
                      <button
                        onClick={() => handleDelete(artist)}
                        className="h-7 flex items-center justify-center text-red-600 hover:text-red-700 px-2"
                        aria-label="Remove artist"
                      >
                        <Trash className="w-4 h-4" />
                      </button>
                    )}
                  </div>
                  <div className="w-[32px]" />
                </div>
              ) : (
                <div 
                  className="relative flex items-center gap-1 h-7"
                  ref={(el) => {
                    menuRefs.current[artist.id] = el
                  }}
                >
                  {menuOpenId === artist.id && (
                    <div 
                      className="absolute right-7 top-0 bg-gray-800 text-white border border-gray-600 rounded-md shadow-lg flex items-center h-7"
                    >
                      <RankDropdown
                        artistId={artist.id}
                        currentTier={rankings[artist.id] || 'unranked'}
                        onUpdateTier={updateTier}
                      />
                      <button
                        onClick={() => handleDelete(artist)}
                        className="h-7 flex items-center justify-center text-red-600 hover:text-red-700 px-2"
                        aria-label="Remove artist"
                      >
                        <Trash className="w-4 h-4" />
                      </button>
                    </div>
                  )}
                  <button
                    onClick={() => {
                      setMenuOpenId((prev) => (prev === artist.id ? null : artist.id))
                    }}
                    className="h-7 text-white text-xl px-2 flex items-center hover:text-gray-300 transition-colors"
                  >
                    <Pencil className="w-4 h-4" />
                  </button>
                </div>
              )
            )}
          </div>
        </div>
      ))}
      {deleteModalArtist && (
        <DeleteConfirmationModal
          artist={deleteModalArtist}
          onConfirm={handleConfirmDelete}
          onCancel={() => setDeleteModalArtist(null)}
        />
      )}
    </div>
  )
}

export function ArtistRankingForm({ queue, rankings, updateTier, removeArtist, isSearchVisible }: Props) {
  const [notForMeExpanded, setNotForMeExpanded] = useState(false)
  const [unrankedExpanded, setUnrankedExpanded] = useState(true)
  const [currentPages, setCurrentPages] = useState<Record<Tier, number>>(() => {
    const initial: Partial<Record<Tier, number>> = {}
    Object.keys(TIER_LABELS).forEach(tier => {
      initial[tier as Tier] = 1
    })
    return initial as Record<Tier, number>
  })

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

  const handlePageChange = (tier: Tier, page: number, totalPages: number) => {
    setCurrentPages(prev => ({
      ...prev,
      [tier]: Math.max(1, Math.min(page, totalPages))
    }))
  }

  return (
    <div className="h-[calc(100vh-200px)]">
      {Object.keys(grouped).length === 0 ? (
        <p>No artists added yet. Use search to add.</p>
      ) : (
        <div className="h-full overflow-y-auto scrollbar-thin scrollbar-track-gray-900 scrollbar-thumb-gray-700 hover:scrollbar-thumb-gray-600 [&::-webkit-scrollbar]:w-2 [&::-webkit-scrollbar-track]:bg-gray-900 [&::-webkit-scrollbar-thumb]:bg-gray-700 [&::-webkit-scrollbar-thumb]:rounded-full hover:[&::-webkit-scrollbar-thumb]:bg-gray-600">
          {(['unranked', ...Object.keys(TIER_LABELS).filter(t => t !== 'unranked')] as Tier[]).map((tier) => {
            const isNotForMe = tier === 'not_for_me'
            const isUnranked = tier === 'unranked'
            const isExpanded = 
              (isNotForMe && notForMeExpanded) || 
              (isUnranked && unrankedExpanded) || 
              (!isNotForMe && !isUnranked)
            const artists = grouped[tier] || []
            const totalPages = Math.ceil(artists.length / ITEMS_PER_PAGE)
            const currentPage = currentPages[tier] || 1

            if (artists.length === 0) return null

            return (
              <div key={tier} className="mb-4">
                <div className={`sticky top-0 bg-surface z-[40] border-b border-gray-800 shadow-sm py-2`}>
                  <h3 className="flex justify-between items-center">
                    <span className={isUnranked ? 'italic' : ''}>
                      {TIER_LABELS[tier]} ({artists.length})
                    </span>
                    <div className="flex items-center gap-4">
                      {totalPages > 1 && (
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => handlePageChange(tier, currentPage - 1, totalPages)}
                            disabled={currentPage === 1}
                            className="p-1 disabled:opacity-50"
                            aria-label="Previous page"
                          >
                            <ChevronLeft className="w-4 h-4" />
                          </button>
                          <span className="text-sm">
                            {currentPage} / {totalPages}
                          </span>
                          <button
                            onClick={() => handlePageChange(tier, currentPage + 1, totalPages)}
                            disabled={currentPage === totalPages}
                            className="p-1 disabled:opacity-50"
                            aria-label="Next page"
                          >
                            <ChevronRight className="w-4 h-4" />
                          </button>
                        </div>
                      )}
                      {(isNotForMe || isUnranked) && (
                        <button
                          onClick={() => isNotForMe ? setNotForMeExpanded(!notForMeExpanded) : setUnrankedExpanded(!unrankedExpanded)}
                          className="text-sm border border-gray-500 px-2 py-1 rounded"
                        >
                          {(isNotForMe ? notForMeExpanded : unrankedExpanded) ? 'Hide' : 'Show'}
                        </button>
                      )}
                    </div>
                  </h3>
                </div>

                {isExpanded && (
                  <PaginatedArtistList
                    artists={artists}
                    rankings={rankings}
                    updateTier={updateTier}
                    removeArtist={removeArtist}
                    currentPage={currentPage}
                    onPageChange={(page) => handlePageChange(tier, page, totalPages)}
                    isUnranked={isUnranked}
                  />
                )}
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}
