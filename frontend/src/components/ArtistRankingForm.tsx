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
          {artists.map((artist) => (
            <div key={artist.id} style={{ marginBottom: '12px' }}>
              <strong>{artist.name}</strong>
              <select
                value={rankings[artist.id] || ''}
                onChange={(e) => updateTier(artist.id, e.target.value as Tier)}
                style={{ marginLeft: '10px' }}
              >
                <option value="">Select a tier</option>
                {(Object.keys(TIER_LABELS) as Tier[]).map((tier) => (
                  <option key={tier} value={tier}>
                    {TIER_LABELS[tier]}
                  </option>
                ))}
              </select>
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
