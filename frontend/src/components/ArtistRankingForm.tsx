import type { Artist, Tier } from '../types'
import { TIER_LABELS } from '../types'
import { useArtistRankings } from '../hooks/useArtistRankings'

type Props = {
  artists: Artist[]
}

export function ArtistRankingForm({ artists }: Props) {
  const { rankings, updateTier, submit } = useArtistRankings()

  const handleSubmit = async () => {
    try {
      await submit()
      alert('Rankings submitted!')
    } catch (err) {
      console.error(err)
      alert('Error submitting rankings.')
    }
  }

  return (
    <div>
      <h2>Rank Artists</h2>
      {artists.length === 0 ? (
        <p>Add artists to start ranking them.</p>
      ) : (
        <>
          {/* Column headers */}
          <div
            style={{
              display: 'flex',
              fontWeight: 'bold',
              padding: '8px 0',
              borderBottom: '1px solid #ccc',
              marginBottom: '12px',
            }}
          >
            <div style={{ flex: 1 }}>Artist</div>
            <div style={{ flexBasis: '200px' }}>Tier</div>
          </div>

          {/* Artist rows */}
          {artists.map((artist) => (
            <div
              key={artist.id}
              style={{
                display: 'flex',
                alignItems: 'center',
                marginBottom: '12px',
                gap: '1rem',
              }}
            >
              <div style={{ flex: 1 }}>
                <strong>{artist.name}</strong>
              </div>
              <div style={{ flexBasis: '200px' }}>
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

          <button onClick={handleSubmit} style={{ marginTop: '20px' }}>
            Submit Rankings
          </button>
        </>
      )}
    </div>
  )
}
