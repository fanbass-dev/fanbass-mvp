import type { Artist, LineupEntry } from '../types/types'

export function normalizeLineupForRanking(
  lineup: LineupEntry[]
): Artist[] {
  const output: Artist[] = []
  const seenArtists = new Set<string>()

  for (const entry of lineup) {
    // If there's a B2B artist in the entry, use that
    const b2bArtist = entry.artists.find(a => a.type === 'b2b')
    if (b2bArtist) {
      if (!seenArtists.has(b2bArtist.id)) {
        output.push(b2bArtist)
        seenArtists.add(b2bArtist.id)
        // Add member artists to seen set to prevent duplicates
        if (b2bArtist.member_ids) {
          b2bArtist.member_ids.forEach(id => seenArtists.add(id))
        }
      }
    } else {
      // Add individual artists if not already seen
      for (const artist of entry.artists) {
        if (!seenArtists.has(artist.id)) {
          output.push(artist)
          seenArtists.add(artist.id)
        }
      }
    }
  }

  return output
}

export function areLineupsEqual(a: LineupEntry[], b: LineupEntry[]): boolean {
  if (a.length !== b.length) return false
  
  return a.every((entry, i) => {
    const other = b[i]
    if (entry.tier !== other.tier) return false
    if (entry.set_note !== other.set_note) return false
    if (entry.display_name !== other.display_name) return false
    if (entry.set_id !== other.set_id) return false
    if (entry.artists.length !== other.artists.length) return false
    
    return entry.artists.every((artist, j) => artist.id === other.artists[j].id)
  })
}
