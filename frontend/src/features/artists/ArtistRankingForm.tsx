import type { Artist } from '../../types/types'
import { TIER_LABELS, type Tier } from '../../constants/tiers'

type Props = {
  queue: Artist[]
  rankings: Record<string, Tier>
  updateTier: (id: string, tier: Tier) => void
}

export function ArtistRankingForm({ queue, rankings, updateTier }: Props) {
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
        (Object.keys(TIER_LABELS) as Tier[]).map((tier) => (
          <div key={tier} style={{ marginBottom: '2rem' }}>
            <h3>{TIER_LABELS[tier]}</h3>
            {grouped[tier]?.map((artist) => (
              <div
                key={artist.id}
                style={{ display: 'flex', alignItems: 'center', marginBottom: '12px' }}
              >
                <div style={{ flex: 1 }}>{artist.name}</div>
                <div style={{ width: '200px' }}>
                  <select
                    value={rankings[artist.id] || 'unranked'}
                    onChange={(e) => updateTier(artist.id, e.target.value as Tier)}
                    style={{ width: '100%' }}
                  >
                    {(Object.keys(TIER_LABELS) as Tier[]).map((t) => (
                      <option key={t} value={t}>
                        {TIER_LABELS[t]}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            ))}
          </div>
        ))
      )}
    </div>
  )
}
