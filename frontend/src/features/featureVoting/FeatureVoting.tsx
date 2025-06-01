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
    <div className="max-w-3xl w-full mx-auto px-4 md:px-8 py-6 text-white">
      <h2 className="text-xl font-semibold mb-4">🧠 Feature Voting</h2>

      <FeatureForm onSubmit={handleSuggest} />

      <div className="mb-4">
        <label htmlFor="sort" className="mr-2">
          Sort by:
        </label>
        <select
          id="sort"
          value={sortBy}
          onChange={(e) => setSortBy(e.target.value as 'top' | 'newest')}
          className="bg-gray-800 text-white border border-gray-600 rounded px-2 py-1"
        >
          <option value="top">Top</option>
          <option value="newest">Newest</option>
        </select>
      </div>

      <FeatureList features={features} onVote={handleVote} />
    </div>
  )
}
