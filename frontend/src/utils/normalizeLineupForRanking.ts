import type { Artist, LineupEntry } from '../types/types'

export type B2BSet = {
  id: string
  name: string
  artist_ids: string[]
}

export function normalizeLineupForRanking(
  lineup: LineupEntry[],
  b2bSets: B2BSet[]
): Artist[] {
  const b2bArtists = new Set<string>()
  const output: Artist[] = []

  const b2bMap = new Map(
    b2bSets.map((set) => [set.artist_ids.slice().sort().join(','), set])
  )

  for (const entry of lineup) {
    const sortedIds = entry.artists.map((a) => a.id).sort()
    const key = sortedIds.join(',')

    const match = b2bMap.get(key)

    if (match && sortedIds.length > 1) {
      output.push({
        id: `b2b-${match.id}`,
        name: match.name,
        is_b2b: true,
        original_ids: sortedIds,
      })

      sortedIds.forEach((id) => b2bArtists.add(id))
    } else {
      for (const artist of entry.artists) {
        if (!b2bArtists.has(artist.id)) {
          output.push(artist)
        }
      }
    }
  }

  return output
}

export function areLineupsEqual(a: LineupEntry[], b: LineupEntry[]): boolean {
  if (a.length !== b.length) return false
  for (let i = 0; i < a.length; i++) {
    const aIds = a[i].artists.map((a) => a.id).sort().join(',')
    const bIds = b[i].artists.map((a) => a.id).sort().join(',')
    if (
      a[i].tier !== b[i].tier ||
      a[i].set_id !== b[i].set_id ||
      a[i].set_note !== b[i].set_note ||
      a[i].display_name !== b[i].display_name ||
      aIds !== bIds
    ) {
      return false
    }
  }
  return true
}
