// src/features/featureVoting/FeatureItem.tsx

import type { Feature } from './types'

type Props = {
  feature: Feature
  onVote: (id: string) => void
}

export function FeatureItem({ feature, onVote }: Props) {
  return (
    <div
      key={feature.id}
      style={{
        border: '1px solid #ccc',
        borderRadius: '8px',
        margin: '8px 0',
        padding: '12px',
        display: 'flex',
        flexDirection: 'column',
        gap: '6px',
      }}
    >
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '8px',
        }}
      >
        <h3 style={{ margin: 0 }}>{feature.title}</h3>
        <span style={{ fontSize: '0.85rem', color: '#555' }}>
          Submitted: {new Date(feature.created_at).toLocaleDateString()}
        </span>
      </div>

      {feature.description && (
        <p style={{ margin: 0, fontSize: '0.95rem' }}>{feature.description}</p>
      )}

      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          fontSize: '0.9rem',
          gap: '8px',
        }}
      >
        <span>
          Status: <strong>{feature.status}</strong>
        </span>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <span>
            Votes: <strong>{feature.vote_count}</strong>
          </span>
          <button onClick={() => onVote(feature.id)} disabled={feature.user_voted}>
            {feature.user_voted ? 'Voted ✅' : 'Upvote'}
          </button>
        </div>
      </div>
    </div>
  )
}
