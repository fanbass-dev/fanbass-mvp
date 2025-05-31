// src/features/featureVoting/FeatureVoting.tsx

import { useFeatureVoting } from './useFeatureVoting'
import { FeatureForm } from './FeatureForm'
import { FeatureList } from './FeatureList'

export function FeatureVoting() {
  const {
    features,
    sortBy,
    setSortBy,
    handleVote,
    handleSuggest,
  } = useFeatureVoting()

  return (
    <div>
      <h2>🧠 Feature Voting</h2>

      <FeatureForm onSubmit={handleSuggest} />

      <div style={{ marginBottom: '12px' }}>
        <label htmlFor="sort">Sort by:</label>
        <select
          id="sort"
          value={sortBy}
          onChange={(e) => setSortBy(e.target.value as 'top' | 'newest')}
          style={{ marginLeft: '8px' }}
        >
          <option value="top">Top</option>
          <option value="newest">Newest</option>
        </select>
      </div>

      <FeatureList features={features} onVote={handleVote} />
    </div>
  )
}
