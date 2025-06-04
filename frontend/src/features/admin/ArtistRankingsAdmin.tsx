import { useEffect, useState } from 'react'
import { supabase } from '../../supabaseClient'
import { Tier, TIER_LABELS } from '../../constants/tiers'

type ArtistRow = {
  id: string
  name: string
  total: number
  [tier: string]: number | string
}

type SortDirection = 'asc' | 'desc'

type PlacementData = {
  artist_id: string
  tier: Tier
}

export default function ArtistRankingsAdmin() {
  const [rows, setRows] = useState<ArtistRow[]>([])
  const [sortColumn, setSortColumn] = useState<string>('name')
  const [sortDirection, setSortDirection] = useState<SortDirection>('asc')
  const [currentPage, setCurrentPage] = useState(1)
  const [isLoading, setIsLoading] = useState(false)
  const [showUnranked, setShowUnranked] = useState(false)
  const [totalPlacements, setTotalPlacements] = useState(0)
  const itemsPerPage = 50

  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true)
      try {
        if (showUnranked) {
          // If showing unranked, fetch all artists
          const { data: artists } = await supabase
            .from('artists')
            .select('id, name')
            .order('name')

          const { data: placements } = await supabase
            .from('artist_placements')
            .select('artist_id, tier')

          const artistMap = Object.fromEntries(
            (artists || [])
              .filter((a): a is { id: string, name: string } => Boolean(a?.name?.trim()))
              .map((a) => [a.id, a.name])
          )

          const grouped: Record<string, ArtistRow> = {}

          // Initialize all artists with 0 rankings
          for (const [id, name] of Object.entries(artistMap)) {
            grouped[id] = {
              id,
              name,
              total: 0,
            }
          }

          // Add rankings
          for (const row of placements || []) {
            const { artist_id, tier } = row as { artist_id: string; tier: Tier }
            if (!grouped[artist_id]) continue

            grouped[artist_id][tier] = (grouped[artist_id][tier] || 0) as number + 1
          }

          const finalRows = Object.values(grouped).map((artistRow) => {
            const total = Object.keys(TIER_LABELS).reduce((sum, tier) => {
              return sum + (Number(artistRow[tier] ?? 0))
            }, 0)
            return { ...artistRow, total }
          })

          setRows(finalRows)
        } else {
          // If only showing ranked artists, first get unique artist IDs from placements
          const { data: placements, error } = await supabase
            .from('artist_placements')
            .select('artist_id, tier')
            .eq('is_admin_placement', false)

          if (error) {
            console.error('Error fetching placements:', error)
            return
          }

          setTotalPlacements(placements?.length || 0)

          // Get unique artist IDs that have rankings
          const rankedArtistIds = Array.from(new Set((placements || []).map((p: PlacementData) => p.artist_id)))

          // Only fetch artists that have rankings
          const { data: rankedArtists } = await supabase
            .from('artists')
            .select('id, name')
            .in('id', rankedArtistIds)
            .order('name')

          const artistMap = Object.fromEntries(
            (rankedArtists || [])
              .filter((a): a is { id: string, name: string } => Boolean(a?.name?.trim()))
              .map((a) => [a.id, a.name])
          )

          const grouped: Record<string, ArtistRow> = {}

          // Process rankings
          for (const row of placements || []) {
            const { artist_id, tier } = row as { artist_id: string; tier: Tier }
            if (!artistMap[artist_id]) continue

            if (!grouped[artist_id]) {
              grouped[artist_id] = {
                id: artist_id,
                name: artistMap[artist_id],
                total: 0,
              }
            }

            grouped[artist_id][tier] = (grouped[artist_id][tier] || 0) as number + 1
          }

          const finalRows = Object.values(grouped).map((artistRow) => {
            const total = Object.keys(TIER_LABELS).reduce((sum, tier) => {
              return sum + (Number(artistRow[tier] ?? 0))
            }, 0)
            return { ...artistRow, total }
          })

          setRows(finalRows)
        }
      } catch (error) {
        console.error('Error fetching data:', error)
      } finally {
        setIsLoading(false)
      }
    }

    fetchData()
  }, [showUnranked])

  const sortedRows = [...rows].sort((a, b) => {
    const aVal = a[sortColumn] ?? 0
    const bVal = b[sortColumn] ?? 0
    if (typeof aVal === 'string' && typeof bVal === 'string') {
      return sortDirection === 'asc' ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal)
    }
    return sortDirection === 'asc'
      ? Number(aVal) - Number(bVal)
      : Number(bVal) - Number(aVal)
  })

  const totalPages = Math.ceil(sortedRows.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const paginatedRows = sortedRows.slice(startIndex, startIndex + itemsPerPage)

  const handleSort = (column: string) => {
    if (column === sortColumn) {
      setSortDirection((prev) => (prev === 'asc' ? 'desc' : 'asc'))
    } else {
      setSortColumn(column)
      setSortDirection('desc')
    }
    setCurrentPage(1) // Reset to first page when sorting changes
  }

  const handlePageChange = (newPage: number) => {
    setCurrentPage(Math.max(1, Math.min(newPage, totalPages)))
  }

  return (
    <div className="max-w-5xl mx-auto px-4 py-8 text-white">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-semibold">Artist Rankings Overview</h2>
        <div className="flex flex-col items-end text-sm text-gray-400">
          <div>Unique Artists: {rows.length}</div>
          <div>Total Rankings: {totalPlacements}</div>
        </div>
      </div>

      {isLoading ? (
        <div className="text-center py-8">Loading...</div>
      ) : (
        <>
          <div className="overflow-auto border border-gray-700 rounded-lg">
            <table className="min-w-full text-sm table-auto">
              <thead className="bg-gray-800 text-left text-xs uppercase border-b border-gray-600">
                <tr>
                  <th
                    className="px-4 py-3 cursor-pointer"
                    onClick={() => handleSort('name')}
                  >
                    Artist {sortColumn === 'name' && (sortDirection === 'asc' ? '▲' : '▼')}
                  </th>
                  {Object.entries(TIER_LABELS).map(([tier, label]) => (
                    <th
                      key={tier}
                      className="px-4 py-3 cursor-pointer text-center"
                      onClick={() => handleSort(tier)}
                    >
                      {label} {sortColumn === tier && (sortDirection === 'asc' ? '▲' : '▼')}
                    </th>
                  ))}
                  <th
                    className="px-4 py-3 cursor-pointer text-center"
                    onClick={() => handleSort('total')}
                  >
                    Total {sortColumn === 'total' && (sortDirection === 'asc' ? '▲' : '▼')}
                  </th>
                </tr>
              </thead>
              <tbody>
                {paginatedRows.map((artist) => (
                  <tr key={artist.id} className="hover:bg-gray-800 transition">
                    <td className="px-4 py-2 whitespace-nowrap">{artist.name}</td>
                    {Object.keys(TIER_LABELS).map((tier) => (
                      <td key={tier} className="px-4 py-2 text-center">
                        {artist[tier] ?? 0}
                      </td>
                    ))}
                    <td className="px-4 py-2 text-center font-semibold">
                      {artist.total ?? 0}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="flex items-center justify-between mt-4 px-4">
            <div className="text-sm text-gray-400">
              Showing {startIndex + 1} to {Math.min(startIndex + itemsPerPage, rows.length)} of {rows.length} artists
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={() => handlePageChange(currentPage - 1)}
                disabled={currentPage === 1}
                className="px-3 py-1 rounded border border-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Previous
              </button>
              <span className="text-sm">
                Page {currentPage} of {totalPages}
              </span>
              <button
                onClick={() => handlePageChange(currentPage + 1)}
                disabled={currentPage === totalPages}
                className="px-3 py-1 rounded border border-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Next
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
