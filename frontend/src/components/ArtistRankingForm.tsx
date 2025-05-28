import type { Artist, Tier } from '../types'
import { TIER_LABELS } from '../types'

type Props = {
  queue: Artist[]
  rankings: Record<string, Tier>
  updateTier: (id: string, tier: Tier) => void
}

export function ArtistRankingForm({ queue, rankings, updateTier }: Props) {
  return (
    <div>
      <h2>My Artists</h2>
      {queue.length === 0 ? (
        <p>No artists added yet. Use search to add.</p>
      ) : (
        <div>
          <div style={{ display: 'flex', fontWeight: 'bold', padding: '8px 0' }}>
            <div style={{ flex: 1 }}>Artist</div>
            <div style={{ width: '200px' }}>Tier</div>
          </div>
          {queue.map((artist) => (
            <div
              key={artist.id}
              style={{ display: 'flex', alignItems: 'center', marginBottom: '12px' }}
            >
              <div style={{ flex: 1 }}>{artist.name}</div>
              <div style={{ width: '200px' }}>
                <select
                  value={rankings[artist.id] || ''}
                  onChange={(e) => updateTier(artist.id, e.target.value as Tier)}
                  style={{ width: '100%' }}
                >
                  <option value="">Select a tier</option>
                  {(Object.keys(TIER_LABELS) as Tier[]).map((tier) => (
                    <option key={tier} value={tier}>
                      {TIER_LABELS[tier]}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
