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

export default function ArtistRankingsAdmin() {
  const [rows, setRows] = useState<ArtistRow[]>([])
  const [sortColumn, setSortColumn] = useState<string>('name')
  const [sortDirection, setSortDirection] = useState<SortDirection>('asc')

  useEffect(() => {
    const fetchData = async () => {
      const { data: placements } = await supabase
        .from('artist_placements')
        .select('artist_id, tier')

      const { data: artists } = await supabase.from('artists').select('id, name')
      const artistMap = Object.fromEntries(
        (artists || [])
          .filter((a) => a.name && a.name.trim() !== '')
          .map((a) => [a.id, a.name])
      )

      const grouped: Record<string, ArtistRow> = {}

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

    fetchData()
  }, [])

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

  const handleSort = (column: string) => {
    if (column === sortColumn) {
      setSortDirection((prev) => (prev === 'asc' ? 'desc' : 'asc'))
    } else {
      setSortColumn(column)
      setSortDirection('desc')
    }
  }

  return (
    <div style={{ padding: '2rem' }}>
      <h2>Artist Rankings Overview</h2>
      <table>
        <thead>
          <tr>
            <th
              style={{ cursor: 'pointer' }}
              onClick={() => handleSort('name')}
            >
              Artist {sortColumn === 'name' && (sortDirection === 'asc' ? '▲' : '▼')}
            </th>
            {Object.entries(TIER_LABELS).map(([tier, label]) => (
              <th
                key={tier}
                style={{ cursor: 'pointer' }}
                onClick={() => handleSort(tier)}
              >
                {label} {sortColumn === tier && (sortDirection === 'asc' ? '▲' : '▼')}
              </th>
            ))}
            <th
              style={{ cursor: 'pointer' }}
              onClick={() => handleSort('total')}
            >
              Total {sortColumn === 'total' && (sortDirection === 'asc' ? '▲' : '▼')}
            </th>
          </tr>
        </thead>
        <tbody>
          {sortedRows.map((artist) => (
            <tr key={artist.id}>
              <td>{artist.name}</td>
              {Object.keys(TIER_LABELS).map((tier) => (
                <td key={tier}>{artist[tier] ?? 0}</td>
              ))}
              <td>{artist.total ?? 0}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
